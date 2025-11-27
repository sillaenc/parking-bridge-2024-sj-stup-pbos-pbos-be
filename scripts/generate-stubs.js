/* eslint-disable no-console */
// Generates endpoint list from swagger_complete.yaml for stub creation.
// Usage: npm run gen:stubs

const fs = require('fs');
const path = require('path');
const YAML = require('yaml');

const swaggerPath = process.env.SWAGGER_PATH
  ? path.resolve(process.env.SWAGGER_PATH)
  : path.join(__dirname, '..', '..', 'swagger_complete.yaml');
const outputPath = path.join(__dirname, '..', 'generated');
const outputFile = path.join(outputPath, 'endpoints.json');

function main() {
  if (!fs.existsSync(swaggerPath)) {
    console.error(`swagger_complete.yaml not found at ${swaggerPath}`);
    process.exit(1);
  }

  const raw = fs.readFileSync(swaggerPath, 'utf8');
  const doc = YAML.parse(raw);
  const endpoints = [];

  const paths = doc.paths || {};
  Object.entries(paths).forEach(([route, ops]) => {
    Object.entries(ops).forEach(([method, info]) => {
      const tags = info.tags || [];
      endpoints.push({
        method: method.toUpperCase(),
        route,
        summary: info.summary || '',
        tags,
      });
    });
  });

  if (!fs.existsSync(outputPath)) {
    fs.mkdirSync(outputPath, { recursive: true });
  }

  fs.writeFileSync(outputFile, JSON.stringify({ count: endpoints.length, endpoints }, null, 2));
  console.log(`Generated ${endpoints.length} endpoints to ${outputFile}`);
}

main();
