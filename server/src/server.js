require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/db');

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  if (process.env.NODE_ENV === 'production') {
    const missing = ['MONGODB_URI', 'JWT_ACCESS_SECRET', 'JWT_REFRESH_SECRET'].filter((k) => !process.env[k]);
    if (missing.length) {
      console.error(`Missing required environment variables: ${missing.join(', ')}`);
      process.exit(1);
    }
  }
  await connectDB();
  app.listen(PORT, () => {
    console.log(`SkillPath Server running in ${process.env.NODE_ENV || 'development'} mode on http://localhost:${PORT}`);
  });
};

startServer();
