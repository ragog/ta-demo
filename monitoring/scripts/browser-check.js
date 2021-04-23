const { chromium } = require("playwright");

(async () => {

 const browser = await chromium.launch();
 const page = await browser.newPage();

 const URL = process.env.ENVIRONMENT_URL || 'https://www.ta-demo.vercel.app'
 await page.goto(URL);

 await browser.close();
})();