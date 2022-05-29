function fn() {
    var host = karate.properties['test.server'] || 'http://127.0.0.1:9191';    
    karate.configure('logPrettyResponse', true);
    karate.configure('report', { showLog: false, showAllSteps: false } );
    var config = { demoBaseUrl: host };
    return config;
  }