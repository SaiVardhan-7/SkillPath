const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
require('dotenv').config({ path: __dirname + '/../.env' });
const connectDB = require('../src/config/db');
const app = require('../src/app');

let server;
let baseUrl;
let accessToken;

before(async () => {
  await connectDB();
  await new Promise((resolve) => {
    server = http.createServer(app);
    server.listen(0, () => {
      const port = server.address().port;
      baseUrl = `http://localhost:${port}`;
      resolve();
    });
  });
});

after(async () => {
  if (server) {
    server.close();
  }
  const mongoose = require('mongoose');
  await mongoose.disconnect();
});

describe('SkillPath Backend API Tests', () => {
  test('GET /api/health should return ok status', async () => {
    const res = await fetch(`${baseUrl}/api/health`);
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.status, 'ok');
  });

  test('POST /api/auth/login with valid demo credentials', async () => {
    const res = await fetch(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'demo@skillpath.dev',
        password: 'Password123!'
      })
    });
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(data.data.accessToken);
    accessToken = data.data.accessToken;
  });

  test('GET /api/auth/me with valid Bearer token', async () => {
    const res = await fetch(`${baseUrl}/api/auth/me`, {
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.data.email, 'demo@skillpath.dev');
  });

  test('GET /api/roadmaps should list all career roadmaps', async () => {
    const res = await fetch(`${baseUrl}/api/roadmaps`);
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(data.data.length >= 5);
  });

  test('GET /api/users/me/roadmap should return user roadmap with unlocked calculations', async () => {
    const res = await fetch(`${baseUrl}/api/users/me/roadmap`, {
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(data.data.progress.completedTopicsCount >= 2);
    assert.ok(data.data.roadmap.stages.length > 0);
  });

  test('GET /api/users/me/dashboard should return unified dashboard and recommendations', async () => {
    const res = await fetch(`${baseUrl}/api/users/me/dashboard`, {
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(data.data.roadmap);
    assert.ok(data.data.dsa);
    assert.ok(data.data.streak);
    assert.ok(Array.isArray(data.data.recommendations));
  });

  test('GET /api/users/me/problems should return tracked DSA problems and stats', async () => {
    const res = await fetch(`${baseUrl}/api/users/me/problems`, {
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(data.analytics.totalSolved >= 1);
  });

  test('POST /api/users/me/projects/:id/resume-bullets should generate valid bullets', async () => {
    // Get user active project
    const userProjectsRes = await fetch(`${baseUrl}/api/users/me/projects`, {
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    const userProjectsData = await userProjectsRes.json();
    assert.ok(userProjectsData.data.length > 0);
    const projId = userProjectsData.data[0]._id;

    const res = await fetch(`${baseUrl}/api/users/me/projects/${projId}/resume-bullets`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${accessToken}` }
    });
    const data = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(data.success, true);
    assert.ok(Array.isArray(data.data.suggestedBullets));
    assert.ok(data.data.suggestedBullets.length > 0);
  });
});
