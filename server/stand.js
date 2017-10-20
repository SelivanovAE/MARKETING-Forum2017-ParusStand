/*
    Сервер стенда
    Главный модуль
*/

//---------------------
//подключение библиотек
//---------------------

const http = require("http"); //библиотека для работы с HTTP
const qs = require("querystring"); //парсер параметров запросов
const conf = require("./config"); //настройки сервера
const parus = require("./parus"); //библиотека высокоуровневого взаимодействия с ПП Парус 8
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

let srv = {};

//-------
//функции
//-------

//запуск сервера
function run() {
    //скажем, что стартуем
    utils.log({ msg: "Starting server..." });
    //опишем WEB-сервер
    srv = http.createServer((req, res) => {
        //разбираем параметры запроса
        utils.parseRequestParams(req, rp => {
            //если запрос не нормальный
            if (rp === utils.REQUEST_STATE_ERR) {
                //не будем его обрабатывать
                utils.log({ type: utils.LOG_TYPE_ERR, msg: "New request: Bad server request!" });
            } else {
                utils.log({ msg: "New request: " + JSON.stringify(rp) });
                //выполняем действие на сервере ПП Парус 8
                parus.makeAction(rp).then(
                    r => {
                        res.writeHead(200, { "Content-Type": "application/json" });
                        res.end(JSON.stringify(r));
                    },
                    e => {
                        res.writeHead(200, { "Content-Type": "application/json" });
                        res.end(JSON.stringify(e));
                    }
                );
            }
        });
    });
    //запускаем WEB-сервер
    srv.listen(conf.SERVER_PORT, () => {
        utils.log({ msg: "Server started at port " + srv.address().port });
        utils.log({ msg: "Available ip's: " + utils.getIPs().join(", ") });
    });
}

//останов сервера
function stop() {
    //сначала прекратим приём сообщений
    utils.log({ msg: "Stoping server..." });
    srv.close(e => {
        utils.log({ msg: "Done" });
        //теперь закроем сессию ПП Парус
        parus.makeAction({ action: parus.PARUS_ACTION_LOGOUT }).then(
            r => {
                //завершаем процесс нормально
                process.exit(0);
            },
            e => {
                //завершаем процесс с кодом ошибки
                process.exit(1);
            }
        );
    });
}

//обработка события "выход" жизненного цикла процесса
process.on("exit", code => {
    //сообщим о завершении процесса
    utils.log({ msg: "Process killed with code " + code });
});

//перехват CTRL + C
process.on("SIGINT", () => {
    //инициируем выход из процесса
    stop();
});

//-----------
//точка входа
//-----------

//старутем
run();
