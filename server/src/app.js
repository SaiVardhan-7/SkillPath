const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const errorHandler = require('./middleware/errorHandler');

const authRoutes = require('./routes/authRoutes');
const roadmapRoutes = require('./routes/roadmapRoutes');
const dsaRoutes = require('./routes/dsaRoutes');
const projectRoutes = require('./routes/projectRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const interviewRoutes = require('./routes/interviewRoutes');

const app = express();

// Middleware
const envOrigins = (process.env.CORS_ORIGIN || '')
  .split(',')
  .map((o) => o.trim().replace(/\/+$/, ''))
  .filter(Boolean);

const defaultOrigins = [
  'https://saivardhan-7.github.io',
  'http://localhost:3000',
  'http://localhost:4200',
  'http://localhost:5000',
  'http://localhost:8080'
];

const allowedOrigins = Array.from(new Set([...defaultOrigins, ...envOrigins]));

const corsOptions = {
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);
    const normalized = origin.replace(/\/+$/, '');
    if (
      allowedOrigins.includes(normalized) ||
      allowedOrigins.includes('*') ||
      /^http:\/\/localhost(:\d+)?$/.test(normalized) ||
      /^http:\/\/127\.0\.0\.1(:\d+)?$/.test(normalized)
    ) {
      return callback(null, true);
    }
    return callback(new Error(`CORS origin not allowed: ${origin}`));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'Origin', 'X-Requested-With']
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

app.use(express.json());

if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

// Root Service Info
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'ok',
    name: 'SkillPath Backend API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      roadmaps: '/api/roadmaps',
      problems: '/api/problems',
      projects: '/api/projects'
    }
  });
});

// Health Checks
const healthHandler = (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'SkillPath Backend API is operational',
    timestamp: new Date().toISOString()
  });
};

app.get('/health', healthHandler);
app.get('/api/health', healthHandler);

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api', roadmapRoutes);
app.use('/api', dsaRoutes);
app.use('/api', projectRoutes);
app.use('/api', dashboardRoutes);
app.use('/api', interviewRoutes);

// 404 handler
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Cannot find route: ${req.method} ${req.originalUrl}`
  });
});

// Centralized Error Handler
app.use(errorHandler);

module.exports = app;
