import puppeteer from 'puppeteer';
import fs from 'node:fs';
import path from 'node:path';

const html = process.env.OD_HTML ?? '/home/ubuntu/.cursor/projects/agent-repos-overdrive-companion/uploads/overdrive-chosen_a570.html';
const outDir = process.env.OD_OUT ?? '/cursor/stores/self/artifacts/rebuild-v1/final/html';
fs.mkdirSync(outDir, { recursive: true });

async function closeSheet(page) {
  const close = await page.$('#close');
  if (close) await close.click();
}

const screens = [
  ['01_login', null],
  ['02_home', async (page) => {
    await page.click('#enter');
    await page.waitForSelector('#nav:not([hidden])', { timeout: 5000 });
  }],
  ['07_confirm_lock', async (page) => {
    await page.click('button[data-action="lock"]');
    await page.waitForSelector('#shade:not([hidden])', { timeout: 3000 });
  }],
  ['08_profile', async (page) => {
    await closeSheet(page);
    await page.click('#profile');
    await page.waitForSelector('#shade:not([hidden])', { timeout: 3000 });
  }],
  ['09_menu', async (page) => {
    await closeSheet(page);
    await page.click('#menu');
    await page.waitForSelector('#shade:not([hidden])', { timeout: 3000 });
  }],
  ['03_camera', async (page) => {
    await closeSheet(page);
    await page.click('button[data-screen="camera"]');
  }],
  ['04_recordings', async (page) => {
    await page.click('button[data-screen="record"]');
  }],
  ['05_trip', async (page) => {
    await page.click('button[data-screen="trip"]');
  }],
  ['06_more', async (page) => {
    await page.click('button[data-screen="more"]');
  }],
];

const browser = await puppeteer.launch({ headless: 'new', args: ['--lang=he-IL'] });
const page = await browser.newPage();
await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 1 });
await page.goto(`file://${html}`, { waitUntil: 'networkidle0' });

for (const [name, action] of screens) {
  if (action) await action(page);
  await new Promise((r) => setTimeout(r, 350));
  await page.screenshot({ path: path.join(outDir, `${name}.png`), fullPage: false });
}

await browser.close();
console.log('HTML captures written to', outDir);
