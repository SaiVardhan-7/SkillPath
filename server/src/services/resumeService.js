/**
 * Generates tailored resume bullets based on actual completed milestones and technologies
 */
const generateProjectResumeBullets = (project, completedMilestoneIds) => {
  const completedIds = new Set(completedMilestoneIds || []);
  const techStackStr = (project.requiredTech || []).join(', ');
  const bullets = [];

  // Base bullet summarizing implementation
  if (completedIds.size > 0) {
    bullets.push(
      `Architected and developed ${project.title} utilizing ${techStackStr}, implementing responsive user interfaces and modular state management.`
    );
  }

  // Feature-specific bullets based on completed milestones
  (project.milestones || []).forEach((milestone) => {
    if (completedIds.has(milestone.milestoneId)) {
      if (milestone.milestoneId.includes('auth')) {
        bullets.push(
          `Implemented secure token-based user authentication and route protection with local encrypted credential storage.`
        );
      } else if (milestone.milestoneId.includes('api') || milestone.milestoneId.includes('backend') || milestone.milestoneId.includes('network')) {
        bullets.push(
          `Integrated RESTful API endpoints with centralized error handling, request caching, and robust offline data persistence.`
        );
      } else if (milestone.milestoneId.includes('state') || milestone.milestoneId.includes('cart') || milestone.milestoneId.includes('data')) {
        bullets.push(
          `Engineered predictable unidirectional state management flows to ensure consistent data synchronization and zero UI jank.`
        );
      } else if (milestone.milestoneId.includes('test') || milestone.milestoneId.includes('ci')) {
        bullets.push(
          `Authored unit and integration test suites covering critical user flows to prevent regressions.`
        );
      } else if (milestone.milestoneId.includes('deploy')) {
        bullets.push(
          `Automated build pipelines and successfully deployed application with configured environment variables and production optimization.`
        );
      } else {
        bullets.push(
          `Delivered ${milestone.title.toLowerCase()}: ${milestone.description}`
        );
      }
    }
  });

  // If user has not completed any milestones yet, give preview of what will unlock
  if (bullets.length === 0) {
    bullets.push(
      `In progress: Developing ${project.title} utilizing ${techStackStr}. Complete project milestones to generate verified resume bullets.`
    );
  }

  return bullets;
};

module.exports = {
  generateProjectResumeBullets
};
