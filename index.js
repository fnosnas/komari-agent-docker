const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const os = require('os');

const PORT = process.env.PORT || 3000;
const AGENT = "./komari-agent";

// ✅ 自动识别 ARM / AMD64
function getDownloadUrl(){

  const base = "https://github.com/komari-monitor/komari-agent/releases/download/1.1.80";

  switch(os.arch()){
    case "arm64":
      console.log("✅ ARM 架构 detected");
      return `${base}/komari-agent-linux-arm64`;

    default:
      console.log("✅ AMD64 架构 detected");
      return `${base}/komari-agent-linux-amd64`;
  }
}

// ✅ 防容器休眠（必须）
http.createServer((req,res)=>{
  res.writeHead(200);
  res.end("OK");
}).listen(PORT);

// ✅ 启动流程（只下载一次）
async function boot(){

  if(!fs.existsSync(AGENT)){

    const DOWNLOAD = getDownloadUrl();

    console.log("⬇ 首次部署，下载 Komari Agent");

    await new Promise(r=>{
      spawn("curl",["-Lf","-o","komari-agent",DOWNLOAD],{stdio:"ignore"})
      .on("close",r);
    });

    await new Promise(r=>{
      spawn("chmod",["+x","komari-agent"])
      .on("close",r);
    });

    console.log("✅ 下载完成");
  }

  run();
}

// ✅ 永久守护 Agent
function run(){

  console.log("✅ Komari 守护已启动");

  const p = spawn(AGENT,[
    "-e","https://xxx.xxx.xxx",
    "-t","xxxxxxxxxxxxxx"
  ],{
    stdio:["ignore","ignore","ignore"]
  });

  // ❗只要 Komari 死了 → 自动复活
  p.on("close",()=>{
    setTimeout(run,3000);
  });
}

boot();
