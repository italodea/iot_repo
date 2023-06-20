const express = require("express");
const mariadb = require("mariadb");
require('dotenv/config');
const cors = require("cors");
const app = express();
const port = 3000;

// Configurações do banco de dados
const pool = mariadb.createPool({
  host: process.env.db_host,
  user: process.env.db_user,
  password: process.env.db_password,
  database: process.env.db_database,
});

app.use(
  cors({
    origin: "*",
    methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
    preflightContinue: false,
    optionsSuccessStatus: 204,
  })
);

app.get("/dados", async (req, res) => {
  let conn;
  try {
    var limit = 200;
    var factor = 12;
    console.log(req.query.limit);
    if (req.query.limit != undefined && req.query.limit > 0) {
      if (req.query.limit <= 1000) {
        limit = req.query.limit;
      }
    }

    if (req.query.factor != undefined && req.query.factor > 0) {
      if (req.query.factor <= 50) {
        factor = req.query.factor;
      }
    }
    conn = await pool.getConnection();
    const rows = await conn.query(
      `SELECT value, date FROM ( SELECT value, date FROM mq2 WHERE id % 1 = 0 ORDER BY id DESC LIMIT ${limit} ) AS subquery ORDER BY date ASC;`
    );

    // Formatar os dados no novo formato
    const formattedData = rows.map((row) => [row.value, formatDate(row.date)]);

    res.json(formattedData);
  } catch (err) {
    console.error(err);
    res.status(500).send("Erro ao obter os dados");
  } finally {
    if (conn) conn.release();
  }
});

// Função para formatar a data
function formatDate(dateString) {
  const date = new Date(dateString);
  // const formattedDate = date.toLocaleString("en-US", {
  //   day: "2-digit",
  //   month: "short",
  //   year: "numeric",
  //   hour: "2-digit",
  //   minute: "2-digit",
  //   second: "2-digit"
  // });

  const formattedDate = date.toLocaleString("en-US", {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });

  return formattedDate;
}

// Função para atualizar a rota quando um novo registro for adicionado
function atualizarDados() {
  pool
    .getConnection()
    .then((conn) => {
      conn
        .query(
          "select value, date from mq2 where id % 12 = 0 order by date desc limit 200;"
        )
        .then((rows) => {
          io.emit("dadosAtualizados", rows);
        })
        .catch((err) => {
          console.error("Erro ao obter os dados:", err);
        })
        .finally(() => {
          conn.release();
        });
    })
    .catch((err) => {
      console.error("Erro ao conectar ao banco de dados:", err);
    });
}

const server = require("http").Server(app);
const io = require("socket.io")(server);

io.on("connection", (socket) => {
  console.log("Novo cliente conectado");
});

// Inicia o servidor
server.listen(port,'0.0.0.0', () => {
  console.log(`Servidor rodando na porta ${port}`);

  // Inicia a função de atualização dos dados quando o servidor é iniciado
  atualizarDados();
});

// Chama a função de atualização dos dados a cada novo registro adicionado à tabela
pool
  .getConnection()
  .then((conn) => {
    const query = conn.query("SELECT COUNT(*) AS count FROM mq2");

    // Cria um watcher para monitorar as alterações na tabela
    const watcher = conn.query(`SELECT * FROM mq2 WATCHER ${query.stream()}`);

    watcher.on("data", () => {
      // Atualiza os dados quando um novo registro é adicionado
      atualizarDados();
    });

    watcher.on("error", (err) => {
      console.error("Erro ao monitorar a tabela:", err);
    });

    watcher.on("end", () => {
      console.log("Watcher encerrado");
      conn.release();
    });
  })
  .catch((err) => {
    console.error("Erro ao conectar ao banco de dados:", err);
  });
