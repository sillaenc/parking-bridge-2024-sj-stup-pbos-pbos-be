/* eslint-disable no-console */
// Generate NestJS controller stubs from generated/endpoints.json (built from swagger_complete.yaml).
// Usage:
//   SWAGGER_PATH=../pbos_be_v2/swagger_complete.yaml npm run gen:stubs
//   npm run gen:controllers
//
// Output: generated/stubs/{tag}.controller.ts

const fs = require('fs');
const path = require('path');

const endpointsJson = path.join(__dirname, '..', 'generated', 'endpoints.json');
const outputDir = path.join(__dirname, '..', 'generated', 'stubs');

const methodDecorator = {
  GET: 'Get',
  POST: 'Post',
  PUT: 'Put',
  PATCH: 'Patch',
  DELETE: 'Delete',
};

function sanitizeMethodName(route, method) {
  const trimmed = route.replace(/^\/api\/v1\//, '').replace(/^\//, '');
  const base = trimmed || 'root';
  const name = base
    .replace(/[:{}]/g, '')
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
  return `${method.toLowerCase()}_${name || 'root'}`;
}

function buildController(tag, endpoints) {
  const className = `${tag.charAt(0).toUpperCase() + tag.slice(1)}StubController`;
  const lines = [];
  lines.push(`import { Controller, HttpException, HttpStatus } from '@nestjs/common';`);
  lines.push(`import { ApiOperation, ApiTags } from '@nestjs/swagger';`);
  lines.push(`import { Get, Post, Put, Patch, Delete } from '@nestjs/common';`);
  lines.push('');
  lines.push(`@ApiTags('${tag}')`);
  lines.push(`@Controller()`);
  lines.push(`export class ${className} {`);
  endpoints.forEach((ep) => {
    const dec = methodDecorator[ep.method] || 'Get';
    const methodName = sanitizeMethodName(ep.route, ep.method);
    lines.push(`  @${dec}('${ep.route}')`);
    lines.push(`  @ApiOperation({ summary: '${(ep.summary || '').replace(/'/g, "\\'")}' })`);
    lines.push(`  async ${methodName}() {`);
    lines.push(
      `    throw new HttpException('Not implemented: ${ep.method} ${ep.route}', HttpStatus.NOT_IMPLEMENTED);`,
    );
    lines.push('  }');
    lines.push('');
  });
  lines.push('}');
  return lines.join('\n');
}

function main() {
  if (!fs.existsSync(endpointsJson)) {
    console.error(`endpoints.json not found. Run npm run gen:stubs first.`);
    process.exit(1);
  }
  const raw = fs.readFileSync(endpointsJson, 'utf8');
  const parsed = JSON.parse(raw);
  const endpoints = parsed.endpoints || [];

  const byTag = {};
  endpoints.forEach((ep) => {
    const tag = (ep.tags && ep.tags[0]) || 'default';
    if (!byTag[tag]) byTag[tag] = [];
    byTag[tag].push(ep);
  });

  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  Object.entries(byTag).forEach(([tag, eps]) => {
    const file = path.join(outputDir, `${tag.toLowerCase()}.controller.ts`);
    const content = buildController(tag, eps);
    fs.writeFileSync(file, content, 'utf8');
    console.log(`Wrote ${eps.length} endpoints to ${file}`);
  });
}

main();
