const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');

const PORT = process.env.PORT || 8080;
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

// ✅ 常见文件类型（index.html 里如果引用了 css/js/图片也能正常加载）
const MIME = {
  ".html": "text/html; charset=utf-8",
  ".css":  "text/css; charset=utf-8",
  ".js":   "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png":  "image/png",
  ".jpg":  "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif":  "image/gif",
  ".svg":  "image/svg+xml",
  ".ico":  "image/x-icon",
  ".webp": "image/webp",
  ".txt":  "text/plain; charset=utf-8"
};

// ✅ 不允许通过网址访问的文件（保护你的代码和 token）
const BLOCKED = ["index.js", "package.json", "komari-agent"];

// ✅ 网站服务：访问域名 → 打开 index.html（同时防容器休眠）
http.createServer((req,res)=>{

  // 健康检查 / 保活
  if(req.url === "/health"){
    res.writeHead(200, {"Content-Type":"text/plain"});
    return res.end("OK");
  }

  let urlPath = "/";
  try{
    urlPath = decodeURIComponent(req.url.split("?")[0]);
  }catch(e){}

  if(urlPath === "/") urlPath = "/index.html";

  const filePath = path.join(__dirname, path.normalize(urlPath));

  // 防止越权访问上级目录，并屏蔽敏感文件
  if(!filePath.startsWith(__dirname) || BLOCKED.includes(path.basename(filePath))){
    res.writeHead(404, {"Content-Type":"text/plain; charset=utf-8"});
    return res.end("Not Found");
  }

  fs.readFile(filePath, (err, data)=>{
    if(err){
      res.writeHead(404, {"Content-Type":"text/plain; charset=utf-8"});
      return res.end("Not Found");
    }
    const type = MIME[path.extname(filePath).toLowerCase()] || "application/octet-stream";
    res.writeHead(200, {"Content-Type": type});
    res.end(data);
  });

}).listen(PORT, "0.0.0.0", ()=>{
  console.log(`✅ 网站已启动，端口 ${PORT}`);
});

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
    "-e","",
    "-t",""
  ],{
    stdio:["ignore","ignore","ignore"]
  });

  // ❗只要 Komari 死了 → 自动复活
  p.on("close",()=>{
    setTimeout(run,3000);
  });
}

boot();
