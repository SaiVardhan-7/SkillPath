require('dotenv').config({ path: __dirname + '/../.env' });
const mongoose = require('mongoose');
const connectDB = require('../src/config/db');
const User = require('../src/models/User');
const Roadmap = require('../src/models/Roadmap');
const RoadmapProgress = require('../src/models/RoadmapProgress');
const { DSAProblem } = require('../src/models/DSAProblem');
const UserProblemProgress = require('../src/models/UserProblemProgress');
const Project = require('../src/models/Project');
const UserProject = require('../src/models/UserProject');
const InterviewQuestion = require('../src/models/InterviewQuestion');
const ActivityLog = require('../src/models/ActivityLog');

const seedData = async () => {
  try {
    await connectDB();
    console.log('Clearing existing data...');

    await User.deleteMany({});
    await Roadmap.deleteMany({});
    await RoadmapProgress.deleteMany({});
    await DSAProblem.deleteMany({});
    await UserProblemProgress.deleteMany({});
    await Project.deleteMany({});
    await UserProject.deleteMany({});
    await InterviewQuestion.deleteMany({});
    await ActivityLog.deleteMany({});

    console.log('Seeding Roadmaps...');

    // 1. SDE Roadmap
    const sdeRoadmap = await Roadmap.create({
      title: 'Software Development Engineer (SDE)',
      slug: 'sde',
      targetRole: 'Software Development Engineer',
      description: 'Comprehensive industry-aligned curriculum from programming fundamentals to system design, DSA mastery, and job interviews.',
      estimatedWeeks: 24,
      stages: [
        {
          stageNumber: 1,
          title: 'Stage 1: Programming Fundamentals',
          description: 'Master core programming constructs, memory, and OOP principles.',
          estimatedHours: 35,
          topics: [
            {
              topicId: 'sde-prog-fund',
              title: 'Variables, Data Types, Loops & Functions',
              description: 'Understand memory models, control flow, functions, and algorithmic thinking.',
              estimatedHours: 12,
              prerequisites: [],
              resources: [
                { title: 'Core CS Foundations Guide', type: 'article', url: 'https://developer.mozilla.org/en-US/docs/Learn/JavaScript/First_steps', durationMinutes: 40 },
                { title: 'CS50 Lecture: C & Memory Fundamentals', type: 'video', url: 'https://cs50.harvard.edu/x/2024/weeks/1/', durationMinutes: 90 }
              ]
            },
            {
              topicId: 'sde-oop',
              title: 'Object-Oriented Programming (OOP)',
              description: 'Encapsulation, inheritance, polymorphism, abstraction, and SOLID design principles.',
              estimatedHours: 15,
              prerequisites: ['sde-prog-fund'],
              resources: [
                { title: 'SOLID Principles in Modern Engineering', type: 'article', url: 'https://en.wikipedia.org/wiki/SOLID', durationMinutes: 45 },
                { title: 'Clean Code: OOP In Practice', type: 'doc', url: 'https://refactoring.guru/design-patterns', durationMinutes: 60 }
              ]
            },
            {
              topicId: 'sde-basic-ps',
              title: 'Basic Problem Solving & Complexity',
              description: 'Time and space complexity analysis, Big-O notation, and math fundamentals.',
              estimatedHours: 8,
              prerequisites: ['sde-prog-fund'],
              resources: [
                { title: 'Big-O Cheat Sheet & Complexity Guide', type: 'doc', url: 'https://www.bigocheatsheet.com/', durationMinutes: 30 }
              ]
            }
          ]
        },
        {
          stageNumber: 2,
          title: 'Stage 2: Data Structures and Algorithms',
          description: 'Essential data structures and algorithmic patterns required for top engineering roles.',
          estimatedHours: 90,
          topics: [
            {
              topicId: 'sde-arrays-strings',
              title: 'Arrays, Two Pointers & Sliding Window',
              description: 'Contiguous memory, subarray problems, prefix sums, and two-pointer techniques.',
              estimatedHours: 15,
              prerequisites: ['sde-basic-ps'],
              resources: [
                { title: 'Sliding Window Pattern Deep-Dive', type: 'article', url: 'https://leetcode.com/discuss/general-discussion/657507/sliding-window-for-beginners-problems-template-sample-solutions', durationMinutes: 45 }
              ]
            },
            {
              topicId: 'sde-linked-lists',
              title: 'Linked Lists & Pointers',
              description: 'Singly, doubly, and circular linked lists, pointer manipulation, and cycle detection.',
              estimatedHours: 10,
              prerequisites: ['sde-prog-fund'],
              resources: [
                { title: 'Floyd Cycle Detection Algorithm', type: 'article', url: 'https://en.wikipedia.org/wiki/Cycle_detection', durationMinutes: 30 }
              ]
            },
            {
              topicId: 'sde-stacks-queues',
              title: 'Stacks, Queues & Monotonic Deques',
              description: 'LIFO, FIFO, monotonic stack patterns, and histogram-style problems.',
              estimatedHours: 12,
              prerequisites: ['sde-arrays-strings'],
              resources: [
                { title: 'Monotonic Stack Explained', type: 'article', url: 'https://leetcode.com/discuss/study-guide/2348674/Monotonic-Stack-Template-and-Questions', durationMinutes: 40 }
              ]
            },
            {
              topicId: 'sde-trees-graphs',
              title: 'Trees, Graphs, BFS & DFS',
              description: 'Binary trees, BST, graph representations, topological sort, Dijkstra, and cycle detection.',
              estimatedHours: 25,
              prerequisites: ['sde-stacks-queues'],
              resources: [
                { title: 'Graph Traversal & Algorithms Guide', type: 'tutorial', url: 'https://cp-algorithms.com/graph/breadth-first-search.html', durationMinutes: 75 }
              ]
            },
            {
              topicId: 'sde-dp',
              title: 'Dynamic Programming & Memoization',
              description: '1D/2D DP, state transition equations, knapsack, and longest common subsequence.',
              estimatedHours: 28,
              prerequisites: ['sde-trees-graphs'],
              resources: [
                { title: 'Dynamic Programming Patterns', type: 'article', url: 'https://leetcode.com/discuss/general-discussion/458695/dynamic-programming-patterns', durationMinutes: 90 }
              ]
            }
          ]
        },
        {
          stageNumber: 3,
          title: 'Stage 3: Core Computer Science',
          description: 'Fundamental CS subjects tested in senior and high-tier engineering interviews.',
          estimatedHours: 50,
          topics: [
            {
              topicId: 'sde-os',
              title: 'Operating Systems & Concurrency',
              description: 'Processes, threads, synchronization, deadlocks, virtual memory, and file systems.',
              estimatedHours: 16,
              prerequisites: ['sde-prog-fund'],
              resources: [
                { title: 'OSTEP: Operating Systems in Three Easy Pieces', type: 'doc', url: 'https://pages.cs.wisc.edu/~remzi/OSTEP/', durationMinutes: 120 }
              ]
            },
            {
              topicId: 'sde-dbms',
              title: 'Database Management Systems & SQL',
              description: 'Relational vs NoSQL, ACID, transactions, B-Tree indexing, and query optimization.',
              estimatedHours: 16,
              prerequisites: ['sde-prog-fund'],
              resources: [
                { title: 'Use The Index, Luke! SQL Indexing Guide', type: 'article', url: 'https://use-the-index-luke.com/', durationMinutes: 60 }
              ]
            },
            {
              topicId: 'sde-cn',
              title: 'Computer Networks & HTTP',
              description: 'OSI model, TCP vs UDP, DNS, TLS/SSL, HTTP/2 & HTTP/3, and WebSockets.',
              estimatedHours: 18,
              prerequisites: ['sde-prog-fund'],
              resources: [
                { title: 'High Performance Browser Networking', type: 'doc', url: 'https://hpbn.co/', durationMinutes: 80 }
              ]
            }
          ]
        },
        {
          stageNumber: 4,
          title: 'Stage 4: Development & System Design',
          description: 'Modern developer toolchains, REST APIs, microservices, and scalable architectures.',
          estimatedHours: 45,
          topics: [
            {
              topicId: 'sde-git-api',
              title: 'Git, GitHub & RESTful API Architecture',
              description: 'Version control branching strategies, semantic versioning, and REST contract design.',
              estimatedHours: 15,
              prerequisites: ['sde-cn'],
              resources: [
                { title: 'Pro Git Book', type: 'doc', url: 'https://git-scm.com/book/en/v2', durationMinutes: 50 }
              ]
            },
            {
              topicId: 'sde-system-design',
              title: 'System Design Fundamentals',
              description: 'Load balancers, CDNs, caching (Redis), message queues (Kafka), and sharding.',
              estimatedHours: 30,
              prerequisites: ['sde-dbms', 'sde-git-api'],
              resources: [
                { title: 'System Design Primer', type: 'doc', url: 'https://github.com/donnemartin/system-design-primer', durationMinutes: 120 }
              ]
            }
          ]
        },
        {
          stageNumber: 5,
          title: 'Stage 5: Practical Projects',
          description: 'End-to-end full-stack and mobile applications with automated testing and deployment.',
          estimatedHours: 60,
          topics: [
            {
              topicId: 'sde-capstone',
              title: 'Production Capstone Application',
              description: 'Build and deploy a full-scale multi-tier application with CI/CD and monitoring.',
              estimatedHours: 60,
              prerequisites: ['sde-system-design'],
              resources: [
                { title: 'Twelve-Factor App Methodology', type: 'article', url: 'https://12factor.net/', durationMinutes: 40 }
              ]
            }
          ]
        },
        {
          stageNumber: 6,
          title: 'Stage 6: Interview Preparation',
          description: 'Coding rounds, mock technical screens, STAR behavioral method, and resume polish.',
          estimatedHours: 30,
          topics: [
            {
              topicId: 'sde-interview-prep',
              title: 'Mock Interviews & Behavioral Mastery',
              description: 'Simulated 45-min coding screens, behavioral storytelling, and offer negotiation.',
              estimatedHours: 30,
              prerequisites: ['sde-capstone', 'sde-dp'],
              resources: [
                { title: 'Tech Interview Handbook', type: 'doc', url: 'https://www.techinterviewhandbook.org/', durationMinutes: 90 }
              ]
            }
          ]
        }
      ]
    });

    // 2. Flutter Developer Roadmap
    await Roadmap.create({
      title: 'Flutter Developer',
      slug: 'flutter',
      targetRole: 'Flutter Developer',
      description: 'Master cross-platform mobile development with Dart, Flutter widgets, Riverpod state management, clean architecture, and store deployments.',
      estimatedWeeks: 20,
      stages: [
        {
          stageNumber: 1,
          title: 'Stage 1: Dart Fundamentals',
          description: 'Type system, null safety, asynchronous programming (Futures & Streams), and functional Dart.',
          estimatedHours: 30,
          topics: [
            {
              topicId: 'flt-dart-core',
              title: 'Dart Syntax & Null Safety',
              description: 'Sound null safety, extension methods, records, patterns, and collections.',
              estimatedHours: 15,
              prerequisites: [],
              resources: [
                { title: 'Dart Tour & Language Specification', type: 'doc', url: 'https://dart.dev/guides/language/language-tour', durationMinutes: 60 }
              ]
            },
            {
              topicId: 'flt-dart-async',
              title: 'Asynchronous Dart (Futures & Streams)',
              description: 'Event loop, microtask queue, async/await, and reactive Stream controllers.',
              estimatedHours: 15,
              prerequisites: ['flt-dart-core'],
              resources: [
                { title: 'Dart Asynchronous Programming', type: 'tutorial', url: 'https://dart.dev/codelabs/async-await', durationMinutes: 45 }
              ]
            }
          ]
        },
        {
          stageNumber: 2,
          title: 'Stage 2: Flutter UI & Material 3',
          description: 'Widget trees, layout constraints, custom styling, responsive designs, and gestures.',
          estimatedHours: 40,
          topics: [
            {
              topicId: 'flt-widget-tree',
              title: 'Widgets, BuildContext & Layouts',
              description: 'Stateless vs Stateful, render tree, Row, Column, Stack, Flex, and slivers.',
              estimatedHours: 20,
              prerequisites: ['flt-dart-core'],
              resources: [
                { title: 'Flutter Architectural Overview', type: 'doc', url: 'https://docs.flutter.dev/resources/architectural-overview', durationMinutes: 60 }
              ]
            },
            {
              topicId: 'flt-theme-m3',
              title: 'Material 3 Theming & Responsive UI',
              description: 'ColorSchemes, dynamic typography, dark mode, LayoutBuilder, and MediaQuery.',
              estimatedHours: 20,
              prerequisites: ['flt-widget-tree'],
              resources: [
                { title: 'Material 3 in Flutter', type: 'article', url: 'https://docs.flutter.dev/ui/design/material', durationMinutes: 40 }
              ]
            }
          ]
        },
        {
          stageNumber: 3,
          title: 'Stage 3: State Management & Navigation',
          description: 'Riverpod 2.0/3.0, GoRouter declarative routing, and separation of concerns.',
          estimatedHours: 40,
          topics: [
            {
              topicId: 'flt-riverpod',
              title: 'Riverpod State Management',
              description: 'NotifierProvider, AsyncNotifier, family providers, autoDispose, and dependency injection.',
              estimatedHours: 25,
              prerequisites: ['flt-widget-tree', 'flt-dart-async'],
              resources: [
                { title: 'Official Riverpod Documentation', type: 'doc', url: 'https://riverpod.dev/', durationMinutes: 80 }
              ]
            },
            {
              topicId: 'flt-gorouter',
              title: 'Declarative Routing with GoRouter',
              description: 'Nested routes, bottom navigation shell routes, redirect guards, and deep linking.',
              estimatedHours: 15,
              prerequisites: ['flt-riverpod'],
              resources: [
                { title: 'GoRouter Guide & Recipes', type: 'article', url: 'https://pub.dev/packages/go_router', durationMinutes: 45 }
              ]
            }
          ]
        },
        {
          stageNumber: 4,
          title: 'Stage 4: Networking, Persistence & Clean Architecture',
          description: 'Dio HTTP client, token interceptors, local caching with Hive/SharedPreferences, and repository pattern.',
          estimatedHours: 45,
          topics: [
            {
              topicId: 'flt-network-clean',
              title: 'Dio REST Integration & Interceptors',
              description: 'JWT authentication interceptors, retry mechanisms, and offline queueing.',
              estimatedHours: 25,
              prerequisites: ['flt-gorouter'],
              resources: [
                { title: 'Dio Package Documentation', type: 'doc', url: 'https://pub.dev/packages/dio', durationMinutes: 40 }
              ]
            },
            {
              topicId: 'flt-clean-arch',
              title: 'Clean Architecture & Testing',
              description: 'Presentation, Domain, and Data layer isolation. Unit tests and widget testing.',
              estimatedHours: 20,
              prerequisites: ['flt-network-clean'],
              resources: [
                { title: 'Clean Architecture with Flutter', type: 'article', url: 'https://resocoder.com/flutter-clean-architecture-tdd/', durationMinutes: 90 }
              ]
            }
          ]
        },
        {
          stageNumber: 5,
          title: 'Stage 5: Production Deployment & Store Release',
          description: 'App bundle builds, code obfuscation, Play Store & App Store guidelines, and CI/CD.',
          estimatedHours: 25,
          topics: [
            {
              topicId: 'flt-release-store',
              title: 'Publishing to App Store & Google Play',
              description: 'Keystores, signing, Fastlane automation, privacy manifests, and crash reporting.',
              estimatedHours: 25,
              prerequisites: ['flt-clean-arch'],
              resources: [
                { title: 'Build and Release Android & iOS Apps', type: 'doc', url: 'https://docs.flutter.dev/deployment/android', durationMinutes: 60 }
              ]
            }
          ]
        }
      ]
    });

    // 3. Frontend Developer Roadmap
    await Roadmap.create({
      title: 'Frontend Developer',
      slug: 'frontend',
      targetRole: 'Frontend Developer',
      description: 'Modern web frontend engineering with React, Next.js, TypeScript, state management, and performance optimization.',
      estimatedWeeks: 18,
      stages: [
        {
          stageNumber: 1,
          title: 'Stage 1: HTML, CSS & Modern JavaScript',
          description: 'Semantic markup, modern flexbox/grid layouts, ES6+ features, and DOM manipulation.',
          estimatedHours: 35,
          topics: [
            { topicId: 'fe-web-core', title: 'HTML5 Semantic Structure & Accessibility (a11y)', description: 'Screen readers, semantic elements, and WCAG compliance.', estimatedHours: 15, prerequisites: [], resources: [] },
            { topicId: 'fe-css-mastery', title: 'Modern CSS, Flexbox, Grid & Responsive Design', description: 'Container queries, animations, CSS variables, and fluid typography.', estimatedHours: 20, prerequisites: ['fe-web-core'], resources: [] }
          ]
        },
        {
          stageNumber: 2,
          title: 'Stage 2: JavaScript & TypeScript Deep Dive',
          description: 'Closures, prototypes, event delegation, TypeScript generics, and strict types.',
          estimatedHours: 40,
          topics: [
            { topicId: 'fe-ts-deep', title: 'TypeScript for Scalable Web Applications', description: 'Interfaces, utility types, discriminating unions, and generics.', estimatedHours: 40, prerequisites: ['fe-css-mastery'], resources: [] }
          ]
        },
        {
          stageNumber: 3,
          title: 'Stage 3: React Ecosystem & Next.js',
          description: 'Server Components, Hooks, Context, React Query, and App Router architecture.',
          estimatedHours: 50,
          topics: [
            { topicId: 'fe-react-next', title: 'Next.js App Router & Server Components', description: 'Server rendering, streaming SSR, actions, and caching strategies.', estimatedHours: 50, prerequisites: ['fe-ts-deep'], resources: [] }
          ]
        }
      ]
    });

    // 4. Backend Developer Roadmap
    await Roadmap.create({
      title: 'Backend Developer',
      slug: 'backend',
      targetRole: 'Backend Developer',
      description: 'Architecting robust server-side systems, databases, distributed caching, security, and cloud deployment.',
      estimatedWeeks: 20,
      stages: [
        {
          stageNumber: 1,
          title: 'Stage 1: Server Runtimes & Node.js/Go',
          description: 'Event loop, streams, buffers, file I/O, and asynchronous patterns.',
          estimatedHours: 35,
          topics: [
            { topicId: 'be-runtime', title: 'Node.js Internals & Event-Driven Architecture', description: 'Libuv, event loop phases, cluster module, and worker threads.', estimatedHours: 35, prerequisites: [], resources: [] }
          ]
        },
        {
          stageNumber: 2,
          title: 'Stage 2: Database Architecture & Caching',
          description: 'Relational data modeling, PostgreSQL, MongoDB, Redis caching, and transactions.',
          estimatedHours: 45,
          topics: [
            { topicId: 'be-db-cache', title: 'PostgreSQL, NoSQL & Redis In-Memory Caching', description: 'Query planning, indexing, connection pooling, and cache invalidation.', estimatedHours: 45, prerequisites: ['be-runtime'], resources: [] }
          ]
        },
        {
          stageNumber: 3,
          title: 'Stage 3: Authentication, Security & Microservices',
          description: 'OAuth 2.0, JWT, rate limiting, Docker containerization, and message brokers.',
          estimatedHours: 50,
          topics: [
            { topicId: 'be-security-micro', title: 'Microservices & Distributed Systems', description: 'Kafka/RabbitMQ message queues, Docker containers, and gRPC services.', estimatedHours: 50, prerequisites: ['be-db-cache'], resources: [] }
          ]
        }
      ]
    });

    // 5. Full-Stack Developer Roadmap
    await Roadmap.create({
      title: 'Full-Stack Developer',
      slug: 'fullstack',
      targetRole: 'Full-Stack Developer',
      description: 'End-to-end software development combining modern frontend frameworks, scalable backend APIs, and cloud deployments.',
      estimatedWeeks: 22,
      stages: [
        {
          stageNumber: 1,
          title: 'Stage 1: Frontend Foundations (React & Next.js)',
          description: 'UI components, client-side routing, and responsive web development.',
          estimatedHours: 40,
          topics: [
            { topicId: 'fs-frontend', title: 'Modern React & Component Design', description: 'Component lifecycles, hooks, and responsive interfaces.', estimatedHours: 40, prerequisites: [], resources: [] }
          ]
        },
        {
          stageNumber: 2,
          title: 'Stage 2: Backend APIs & Database Integration',
          description: 'Node.js, Express, MongoDB/PostgreSQL, and authentication.',
          estimatedHours: 45,
          topics: [
            { topicId: 'fs-backend', title: 'REST & GraphQL APIs with Database Persistence', description: 'API contracts, ORM/ODM integration, and JWT auth.', estimatedHours: 45, prerequisites: ['fs-frontend'], resources: [] }
          ]
        },
        {
          stageNumber: 3,
          title: 'Stage 3: DevOps & Full-Stack Deployment',
          description: 'Docker, CI/CD pipelines, AWS/Vercel deployment, and monitoring.',
          estimatedHours: 35,
          topics: [
            { topicId: 'fs-devops', title: 'Containerization & Cloud Production Releases', description: 'Dockerizing full-stack apps and automating deployments.', estimatedHours: 35, prerequisites: ['fs-backend'], resources: [] }
          ]
        }
      ]
    });

    console.log('Seeding DSA Problems Catalog...');

    const presetProblems = [
      // Arrays & Strings
      { title: 'Two Sum', url: 'https://leetcode.com/problems/two-sum/', platform: 'LeetCode', topic: 'Arrays', difficulty: 'Easy', suggestedTimeMinutes: 20 },
      { title: 'Best Time to Buy and Sell Stock', url: 'https://leetcode.com/problems/best-time-to-buy-and-sell-stock/', platform: 'LeetCode', topic: 'Arrays', difficulty: 'Easy', suggestedTimeMinutes: 20 },
      { title: 'Contains Duplicate', url: 'https://leetcode.com/problems/contains-duplicate/', platform: 'LeetCode', topic: 'Arrays', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'Product of Array Except Self', url: 'https://leetcode.com/problems/product-of-array-except-self/', platform: 'LeetCode', topic: 'Arrays', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Maximum Subarray (Kadane)', url: 'https://leetcode.com/problems/maximum-subarray/', platform: 'LeetCode', topic: 'Arrays', difficulty: 'Medium', suggestedTimeMinutes: 25 },
      { title: 'Trapping Rain Water', url: 'https://leetcode.com/problems/trapping-rain-water/', platform: 'LeetCode', topic: 'Arrays', difficulty: 'Hard', suggestedTimeMinutes: 45 },

      // Strings
      { title: 'Valid Anagram', url: 'https://leetcode.com/problems/valid-anagram/', platform: 'LeetCode', topic: 'Strings', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'Valid Palindrome', url: 'https://leetcode.com/problems/valid-palindrome/', platform: 'LeetCode', topic: 'Strings', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'Longest Substring Without Repeating Characters', url: 'https://leetcode.com/problems/longest-substring-without-repeating-characters/', platform: 'LeetCode', topic: 'Strings', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Longest Palindromic Substring', url: 'https://leetcode.com/problems/longest-palindromic-substring/', platform: 'LeetCode', topic: 'Strings', difficulty: 'Medium', suggestedTimeMinutes: 35 },

      // Two Pointers & Sliding Window
      { title: 'Container With Most Water', url: 'https://leetcode.com/problems/container-with-most-water/', platform: 'LeetCode', topic: 'Two pointers', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: '3Sum', url: 'https://leetcode.com/problems/3sum/', platform: 'LeetCode', topic: 'Two pointers', difficulty: 'Medium', suggestedTimeMinutes: 35 },
      { title: 'Minimum Window Substring', url: 'https://leetcode.com/problems/minimum-window-substring/', platform: 'LeetCode', topic: 'Sliding window', difficulty: 'Hard', suggestedTimeMinutes: 45 },

      // Linked Lists
      { title: 'Reverse Linked List', url: 'https://leetcode.com/problems/reverse-linked-list/', platform: 'LeetCode', topic: 'Linked lists', difficulty: 'Easy', suggestedTimeMinutes: 20 },
      { title: 'Merge Two Sorted Lists', url: 'https://leetcode.com/problems/merge-two-sorted-lists/', platform: 'LeetCode', topic: 'Linked lists', difficulty: 'Easy', suggestedTimeMinutes: 20 },
      { title: 'Linked List Cycle', url: 'https://leetcode.com/problems/linked-list-cycle/', platform: 'LeetCode', topic: 'Linked lists', difficulty: 'Easy', suggestedTimeMinutes: 20 },
      { title: 'Remove Nth Node From End of List', url: 'https://leetcode.com/problems/remove-nth-node-from-end-of-list/', platform: 'LeetCode', topic: 'Linked lists', difficulty: 'Medium', suggestedTimeMinutes: 25 },
      { title: 'Merge k Sorted Lists', url: 'https://leetcode.com/problems/merge-k-sorted-lists/', platform: 'LeetCode', topic: 'Linked lists', difficulty: 'Hard', suggestedTimeMinutes: 45 },

      // Stacks and Queues
      { title: 'Valid Parentheses', url: 'https://leetcode.com/problems/valid-parentheses/', platform: 'LeetCode', topic: 'Stacks and queues', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'Min Stack', url: 'https://leetcode.com/problems/min-stack/', platform: 'LeetCode', topic: 'Stacks and queues', difficulty: 'Medium', suggestedTimeMinutes: 25 },
      { title: 'Daily Temperatures', url: 'https://leetcode.com/problems/daily-temperatures/', platform: 'LeetCode', topic: 'Stacks and queues', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Largest Rectangle in Histogram', url: 'https://leetcode.com/problems/largest-rectangle-in-histogram/', platform: 'LeetCode', topic: 'Stacks and queues', difficulty: 'Hard', suggestedTimeMinutes: 50 },

      // Binary Search
      { title: 'Binary Search', url: 'https://leetcode.com/problems/binary-search/', platform: 'LeetCode', topic: 'Binary search', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'Search in Rotated Sorted Array', url: 'https://leetcode.com/problems/search-in-rotated-sorted-array/', platform: 'LeetCode', topic: 'Binary search', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Find Minimum in Rotated Sorted Array', url: 'https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/', platform: 'LeetCode', topic: 'Binary search', difficulty: 'Medium', suggestedTimeMinutes: 25 },
      { title: 'Median of Two Sorted Arrays', url: 'https://leetcode.com/problems/median-of-two-sorted-arrays/', platform: 'LeetCode', topic: 'Binary search', difficulty: 'Hard', suggestedTimeMinutes: 50 },

      // Trees
      { title: 'Maximum Depth of Binary Tree', url: 'https://leetcode.com/problems/maximum-depth-of-binary-tree/', platform: 'LeetCode', topic: 'Trees', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'Invert Binary Tree', url: 'https://leetcode.com/problems/invert-binary-tree/', platform: 'LeetCode', topic: 'Trees', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'Validate Binary Search Tree', url: 'https://leetcode.com/problems/validate-binary-search-tree/', platform: 'LeetCode', topic: 'Trees', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Binary Tree Level Order Traversal', url: 'https://leetcode.com/problems/binary-tree-level-order-traversal/', platform: 'LeetCode', topic: 'Trees', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Lowest Common Ancestor of a BST', url: 'https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/', platform: 'LeetCode', topic: 'Trees', difficulty: 'Medium', suggestedTimeMinutes: 25 },
      { title: 'Binary Tree Maximum Path Sum', url: 'https://leetcode.com/problems/binary-tree-maximum-path-sum/', platform: 'LeetCode', topic: 'Trees', difficulty: 'Hard', suggestedTimeMinutes: 45 },

      // Graphs
      { title: 'Number of Islands', url: 'https://leetcode.com/problems/number-of-islands/', platform: 'LeetCode', topic: 'Graphs', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Clone Graph', url: 'https://leetcode.com/problems/clone-graph/', platform: 'LeetCode', topic: 'Graphs', difficulty: 'Medium', suggestedTimeMinutes: 30 },
      { title: 'Course Schedule', url: 'https://leetcode.com/problems/course-schedule/', platform: 'LeetCode', topic: 'Graphs', difficulty: 'Medium', suggestedTimeMinutes: 35 },
      { title: 'Word Ladder', url: 'https://leetcode.com/problems/word-ladder/', platform: 'LeetCode', topic: 'Graphs', difficulty: 'Hard', suggestedTimeMinutes: 45 },

      // Dynamic Programming
      { title: 'Climbing Stairs', url: 'https://leetcode.com/problems/climbing-stairs/', platform: 'LeetCode', topic: 'Dynamic programming', difficulty: 'Easy', suggestedTimeMinutes: 15 },
      { title: 'House Robber', url: 'https://leetcode.com/problems/house-robber/', platform: 'LeetCode', topic: 'Dynamic programming', difficulty: 'Medium', suggestedTimeMinutes: 25 },
      { title: 'Coin Change', url: 'https://leetcode.com/problems/coin-change/', platform: 'LeetCode', topic: 'Dynamic programming', difficulty: 'Medium', suggestedTimeMinutes: 35 },
      { title: 'Longest Increasing Subsequence', url: 'https://leetcode.com/problems/longest-increasing-subsequence/', platform: 'LeetCode', topic: 'Dynamic programming', difficulty: 'Medium', suggestedTimeMinutes: 35 },
      { title: 'Edit Distance', url: 'https://leetcode.com/problems/edit-distance/', platform: 'LeetCode', topic: 'Dynamic programming', difficulty: 'Hard', suggestedTimeMinutes: 45 }
    ];

    const seededDSA = await DSAProblem.insertMany(presetProblems);

    console.log('Seeding Project Learning Hub Projects...');

    const sampleProjects = [
      {
        title: 'Task Management Application',
        slug: 'task-management-application',
        domain: 'Flutter development',
        difficulty: 'Beginner',
        requiredTech: ['Flutter', 'Riverpod', 'SQLite / Hive', 'Material 3'],
        estimatedHours: 20,
        prerequisites: ['Dart syntax', 'Flutter widgets', 'Basic state management'],
        description: 'A modular offline-first task tracker with categories, priority tags, due dates, local push notifications, and filterable dashboards.',
        learningObjectives: [
          'Master local SQLite or Hive persistence in Flutter',
          'Implement reactive Riverpod state updates across screens',
          'Design sleek Material 3 forms and custom swipe-to-action cards'
        ],
        stepByStepPlan: [
          { stepNumber: 1, title: 'Project Scaffolding & Theme Setup', description: 'Configure Material 3 color schemes, typography, and folder structure.' },
          { stepNumber: 2, title: 'Local Database Schema & CRUD', description: 'Create task model, database repository, and data access objects.' },
          { stepNumber: 3, title: 'State Management with Riverpod', description: 'Build NotifierProvider for active filters, sorting, and task lists.' },
          { stepNumber: 4, title: 'Interactive UI & Notifications', description: 'Implement dismissible list items, filter chips, and reminder alerts.' }
        ],
        milestones: [
          { milestoneId: 'task-ms-1', title: 'Data Architecture & Model Definition', description: 'Define Task entity with priority, status, and due timestamp.' },
          { milestoneId: 'task-ms-2', title: 'Local Persistence Integration', description: 'Implement offline CRUD storage using local database.' },
          { milestoneId: 'task-ms-3', title: 'Reactive Riverpod State', description: 'Create dynamic filtering by completion status and category.' },
          { milestoneId: 'task-ms-4', title: 'Polished UI & Form Validation', description: 'Deliver complete task creation bottom-sheet with input validation.' }
        ],
        suggestedResumeBullets: [
          'Engineered an offline-first Task Management mobile app using Flutter and Riverpod, reducing app launch latency to sub-100ms.',
          'Implemented persistent SQLite database layer with full CRUD operations and custom index optimizations for sub-second query execution.',
          'Built responsive Material 3 UI supporting dynamic theming and gesture-based task status transitions.'
        ]
      },
      {
        title: 'Expense Tracker & Budget Analyzer',
        slug: 'expense-tracker-and-budget-analyzer',
        domain: 'Flutter development',
        difficulty: 'Intermediate',
        requiredTech: ['Flutter', 'fl_chart', 'Riverpod', 'Secure Storage'],
        estimatedHours: 28,
        prerequisites: ['Flutter State Management', 'Data visualization', 'Async programming'],
        description: 'Personal finance companion featuring interactive expense analytics, monthly budget thresholds, transaction categorizations, and CSV export.',
        learningObjectives: [
          'Integrate interactive line charts and pie charts using fl_chart',
          'Calculate real-time monthly budget burn rates and alerts',
          'Handle currency localization and financial precision arithmetic'
        ],
        stepByStepPlan: [
          { stepNumber: 1, title: 'Finance Data Modeling', description: 'Define Transaction and Budget models with Decimal accuracy.' },
          { stepNumber: 2, title: 'Chart & Analytics Engine', description: 'Aggregate category expenses and wire into interactive fl_chart widgets.' },
          { stepNumber: 3, title: 'Budget Alerts & Filters', description: 'Implement warning indicators when category spending exceeds 80%.' }
        ],
        milestones: [
          { milestoneId: 'exp-ms-1', title: 'Transaction Schema & Repository', description: 'Store transactions with timestamp, category, and decimal amount.' },
          { milestoneId: 'exp-ms-2', title: 'Interactive Category Analytics', description: 'Render monthly expense breakdown charts using fl_chart.' },
          { milestoneId: 'exp-ms-3', title: 'Budget Warning System', description: 'Trigger visual notifications when category expenses approach limit.' }
        ],
        suggestedResumeBullets: [
          'Developed an interactive personal finance mobile application with Flutter and fl_chart, visualizing spending patterns across monthly cycles.',
          'Built real-time budget forecasting engine that computes burn rates and generates automated threshold alerts.',
          'Engineered seamless CSV data export and encrypted token storage for financial privacy.'
        ]
      },
      {
        title: 'E-Commerce Marketplace Platform',
        slug: 'ecommerce-marketplace-platform',
        domain: 'MERN stack',
        difficulty: 'Advanced',
        requiredTech: ['Node.js', 'Express', 'MongoDB', 'React', 'JWT', 'Stripe'],
        estimatedHours: 45,
        prerequisites: ['REST APIs', 'NoSQL modeling', 'JWT auth', 'React state'],
        description: 'Scalable multi-vendor e-commerce platform with catalog search, inventory tracking, shopping cart synchronization, and checkout workflow.',
        learningObjectives: [
          'Implement atomic inventory decrementing under concurrent orders',
          'Integrate Stripe payment intent lifecycle and webhooks',
          'Build paginated product search with multiple facet filters'
        ],
        stepByStepPlan: [
          { stepNumber: 1, title: 'Product & Order Schema Modeling', description: 'Define schemas with inventory counters and shipping address specs.' },
          { stepNumber: 2, title: 'Payment Processing & Webhook Handler', description: 'Implement Stripe backend checkout sessions and verify webhooks.' },
          { stepNumber: 3, title: 'Cart State & Optimistic UI', description: 'Build client cart sync with server-side validation.' }
        ],
        milestones: [
          { milestoneId: 'ecom-ms-1', title: 'Catalog Search & Facet Filters', description: 'Build multi-filter product queries with text indexing.' },
          { milestoneId: 'ecom-ms-2', title: 'JWT Authentication & Cart Sync', description: 'Secure user carts across sessions with token-based access.' },
          { milestoneId: 'ecom-ms-3', title: 'Checkout & Payment Lifecycle', description: 'Integrate checkout session creation and order state transitions.' }
        ],
        suggestedResumeBullets: [
          'Architected full-stack e-commerce solution using Node.js, Express, and MongoDB handling concurrent product filtering and ordering.',
          'Implemented end-to-end checkout flow integrating Stripe payment intents and idempotent webhook handlers.',
          'Optimized database indexes and product catalog query performance, achieving sub-50ms API response times.'
        ]
      },
      {
        title: 'Real-Time Team Collaboration Chat',
        slug: 'real-time-team-collaboration-chat',
        domain: 'Developer productivity tools',
        difficulty: 'Intermediate',
        requiredTech: ['WebSockets', 'Node.js', 'Flutter / React', 'Redis'],
        estimatedHours: 32,
        prerequisites: ['Socket protocol', 'Event emitters', 'Presence tracking'],
        description: 'High-throughput group messaging workspace featuring channels, direct messages, real-time typing indicators, read receipts, and online presence.',
        learningObjectives: [
          'Manage persistent WebSocket connections with automatic reconnect',
          'Implement Redis pub/sub for scaling across server instances',
          'Build optimistic UI message delivery states'
        ],
        stepByStepPlan: [
          { stepNumber: 1, title: 'WebSocket Server Protocol', description: 'Setup socket server with authentication token handshake.' },
          { stepNumber: 2, title: 'Channel & Message Routing', description: 'Route group broadcasts and direct messages reliably.' },
          { stepNumber: 3, title: 'Presence & Typing Indicators', description: 'Track user active states using Redis heartbeat keys.' }
        ],
        milestones: [
          { milestoneId: 'chat-ms-1', title: 'Socket Handshake & Auth', description: 'Verify JWT credentials during WebSocket upgrade.' },
          { milestoneId: 'chat-ms-2', title: 'Real-time Message Broadcast', description: 'Deliver messages with delivered and read receipt statuses.' },
          { milestoneId: 'chat-ms-3', title: 'Channel Presence & Typing State', description: 'Broadcast active participant indicators and channel member lists.' }
        ],
        suggestedResumeBullets: [
          'Designed real-time messaging architecture utilizing WebSockets and Redis Pub/Sub for sub-50ms message latency.',
          'Engineered connection resilience mechanism with automatic exponential-backoff reconnect and message offline queueing.',
          'Implemented granular delivery tracking including instant typing indicators and per-user read receipts.'
        ]
      },
      {
        title: 'DSA Visualizer & Algorithm Sandbox',
        slug: 'dsa-visualizer-algorithm-sandbox',
        domain: 'Developer productivity tools',
        difficulty: 'Intermediate',
        requiredTech: ['Flutter / Web', 'Canvas API', 'State Machine', 'Algorithms'],
        estimatedHours: 25,
        prerequisites: ['Sorting algorithms', 'Graph traversals', 'Animation controllers'],
        description: 'Interactive educational canvas animating pathfinding (Dijkstra, A*), sorting algorithms (Quicksort, Mergesort), and binary search tree rebalancing.',
        learningObjectives: [
          'Create step-by-step yield-based execution generators for algorithms',
          'Render high frame-rate visualizations on Flutter canvas',
          'Provide speed control, step-back, and custom test input capabilities'
        ],
        stepByStepPlan: [
          { stepNumber: 1, title: 'Canvas Grid & Node Architecture', description: 'Render responsive node grid with wall, start, and end designations.' },
          { stepNumber: 2, title: 'Algorithm Step Generators', description: 'Implement step generators yielding intermediate traversal states.' },
          { stepNumber: 3, title: 'Interactive Playback Controller', description: 'Build play, pause, scrub, and speed adjustment controls.' }
        ],
        milestones: [
          { milestoneId: 'dsa-vis-ms-1', title: 'Interactive Grid Rendering', description: 'Draw grid canvas supporting drag-to-draw walls and endpoints.' },
          { milestoneId: 'dsa-vis-ms-2', title: 'Dijkstra & BFS Visualizer', description: 'Animate frontier expansion and shortest-path reconstruction.' },
          { milestoneId: 'dsa-vis-ms-3', title: 'Sorting Algorithm Comparisons', description: 'Visualize bar comparisons, pivots, and swaps in real time.' }
        ],
        suggestedResumeBullets: [
          'Engineered interactive algorithm visualization engine supporting step-by-step playback of pathfinding and sorting algorithms.',
          'Leveraged custom canvas rendering and generator state machines to animate complex graph traversals at 60 FPS.',
          'Built intuitive interactive controls allowing users to benchmark algorithm iterations and memory consumption.'
        ]
      }
    ];

    const seededProjects = await Project.insertMany(sampleProjects);

    console.log('Seeding Technical & Behavioral Interview Questions...');

    const sampleQuestions = [
      {
        topic: 'Data Structures',
        category: 'Technical',
        question: 'Explain the difference between an Array and a Linked List in memory and access complexity.',
        answerKeyPoints: [
          'Arrays allocate contiguous memory blocks, granting O(1) random index access via pointer arithmetic.',
          'Linked Lists allocate nodes dynamically in the heap with pointer overhead; random access requires O(n) linear traversal.',
          'Insertion/deletion in arrays takes O(n) due to element shifting (unless at the end with amortized capacity), while linked lists achieve O(1) insertion given a direct pointer to the target node.'
        ],
        difficulty: 'Easy',
        companyTags: ['Amazon', 'Google', 'Microsoft']
      },
      {
        topic: 'Algorithms',
        category: 'Technical',
        question: 'How does QuickSort work, and why is its worst-case time complexity O(n^2)? How can we mitigate this?',
        answerKeyPoints: [
          'QuickSort uses divide-and-conquer: selects a pivot, partitions array around it, and recurses on left and right subarrays.',
          'Average time complexity is O(n log n); worst case O(n^2) occurs when the pivot is consistently the smallest or largest element (e.g. already sorted array with naive first/last element pivot).',
          'Mitigation: randomized pivot selection, median-of-three heuristic, or switching to heapsort (Introsort).'
        ],
        difficulty: 'Medium',
        companyTags: ['Amazon', 'Meta', 'Apple']
      },
      {
        topic: 'System Design',
        category: 'System Design',
        question: 'How would you design a URL Shortener service like Bitly handling 100M new URLs per month?',
        answerKeyPoints: [
          'Capacity estimation: 100M writes/month ≈ 40 writes/sec, with 10x read ratio ≈ 400 reads/sec.',
          'Short hash generation: Base62 encoding ([a-z, A-Z, 0-9]) on a 64-bit unique ID generates 7-character strings (62^7 ≈ 3.5 trillion URLs).',
          'Distributed ID generation: Snowflake ID generator or database auto-increment ranges to prevent collisions.',
          'Caching: Cache top 20% most accessed URLs using Redis with LRU eviction policy.',
          'Redirect: Return HTTP 302 (temporary redirect) for analytics tracking or HTTP 301 for browser caching.'
        ],
        difficulty: 'Hard',
        companyTags: ['Google', 'Meta', 'Uber']
      },
      {
        topic: 'Core CS',
        category: 'Technical',
        question: 'What are ACID properties in relational database management systems?',
        answerKeyPoints: [
          'Atomicity: All operations in a transaction succeed together or are completely rolled back.',
          'Consistency: Transactions transition the database from one valid state to another, preserving all constraints.',
          'Isolation: Concurrent transactions execute without interfering with one another (varying isolation levels: Read Uncommitted, Read Committed, Repeatable Read, Serializable).',
          'Durability: Once committed, transaction results survive system crashes via Write-Ahead Logging (WAL).'
        ],
        difficulty: 'Medium',
        companyTags: ['Microsoft', 'Oracle', 'Goldman Sachs']
      },
      {
        topic: 'Leadership & Conflict',
        category: 'Behavioral',
        question: 'Tell me about a time you had a technical disagreement with a teammate. How did you resolve it?',
        answerKeyPoints: [
          'Situation: Describe the project context and the specific technical decision (e.g. database choice or state management pattern).',
          'Task: Frame your objective: selecting the optimal engineering tradeoff while preserving team cohesion.',
          'Action: Listened empathetically, gathered empirical benchmarks/data, built quick proof-of-concept prototypes, and aligned on customer requirements.',
          'Result: Successfully launched on schedule with quantifiable stability, maintaining high trust within the team.'
        ],
        difficulty: 'Medium',
        companyTags: ['Amazon', 'Google', 'Meta']
      },
      {
        topic: 'Overcoming Challenges',
        category: 'Behavioral',
        question: 'Describe a situation where a project missed a deadline or failed. What did you learn and do differently?',
        answerKeyPoints: [
          'Situation: Transparently acknowledge an ambitious scope or unforeseen technical blocker.',
          'Task: Took accountability without deflecting blame.',
          'Action: Communicated proactively with stakeholders, implemented rigorous milestone checkpoints, and broke tasks into smaller testable increments.',
          'Result: Delivered a reliable post-mortem with actionable preventive steps that improved subsequent sprint velocity.'
        ],
        difficulty: 'Medium',
        companyTags: ['Amazon', 'Netflix', 'Microsoft']
      }
    ];

    await InterviewQuestion.insertMany(sampleQuestions);

    console.log('Seeding Demo User for Testing...');

    const demoUser = await User.create({
      name: 'Alex Developer',
      email: 'demo@skillpath.dev',
      password: 'Password123!',
      targetRole: 'Software Development Engineer',
      currentSkillLevel: 'Intermediate',
      dailyStudyTimeMinutes: 90,
      learningGoals: [
        'Master LeetCode Medium/Hard patterns',
        'Build production-ready portfolio projects',
        'Crack top-tier software engineering interviews'
      ],
      isOnboarded: true
    });

    // Seed Demo User Roadmap Progress
    await RoadmapProgress.create({
      userId: demoUser._id,
      roadmapId: sdeRoadmap._id,
      completedTopics: ['sde-prog-fund', 'sde-basic-ps'],
      inProgressTopics: ['sde-oop', 'sde-arrays-strings'],
      bookmarkedResources: [
        {
          topicId: 'sde-arrays-strings',
          title: 'Sliding Window Pattern Deep-Dive',
          url: 'https://leetcode.com/discuss/general-discussion/657507/sliding-window-for-beginners-problems-template-sample-solutions',
          type: 'article',
          addedAt: new Date()
        }
      ],
      currentStageNumber: 1
    });

    // Seed Demo User Problems Progress
    const twoSum = seededDSA.find((p) => p.title === 'Two Sum');
    const validAnagram = seededDSA.find((p) => p.title === 'Valid Anagram');
    const threeSum = seededDSA.find((p) => p.title === '3Sum');
    const trapWater = seededDSA.find((p) => p.title === 'Trapping Rain Water');

    const pastDate = new Date();
    pastDate.setDate(pastDate.getDate() - 4);

    const revisionDue = new Date();
    revisionDue.setDate(revisionDue.getDate() - 1); // Due yesterday!

    await UserProblemProgress.create([
      {
        userId: demoUser._id,
        problemId: twoSum._id,
        title: twoSum.title,
        url: twoSum.url,
        platform: twoSum.platform,
        topic: twoSum.topic,
        difficulty: twoSum.difficulty,
        status: 'solved',
        isBookmarked: true,
        notes: 'Used hash map for O(n) one-pass lookup of complement.',
        mistakes: 'Initial brute force was O(n^2). Watch out for using the same element twice.',
        dateSolved: pastDate,
        revisionScheduledDate: revisionDue,
        revisionIntervalDays: 3,
        revisionCount: 1
      },
      {
        userId: demoUser._id,
        problemId: validAnagram._id,
        title: validAnagram.title,
        url: validAnagram.url,
        platform: validAnagram.platform,
        topic: validAnagram.topic,
        difficulty: validAnagram.difficulty,
        status: 'solved',
        isBookmarked: false,
        notes: 'Frequency count array of size 26.',
        dateSolved: new Date(),
        revisionScheduledDate: new Date(Date.now() + 3 * 24 * 3600 * 1000),
        revisionIntervalDays: 3,
        revisionCount: 0
      },
      {
        userId: demoUser._id,
        problemId: threeSum._id,
        title: threeSum.title,
        url: threeSum.url,
        platform: threeSum.platform,
        topic: threeSum.topic,
        difficulty: threeSum.difficulty,
        status: 'attempted',
        isBookmarked: true,
        notes: 'Sort array first. Skip duplicate values when moving two pointers.',
        mistakes: 'Handling duplicates for both outer loop and inner two-pointers is tricky.'
      },
      {
        userId: demoUser._id,
        problemId: trapWater._id,
        title: trapWater.title,
        url: trapWater.url,
        platform: trapWater.platform,
        topic: trapWater.topic,
        difficulty: trapWater.difficulty,
        status: 'attempted',
        isBookmarked: true,
        notes: 'Need to review two-pointer vs monotonic stack approach.'
      }
    ]);

    // Seed Demo User Project
    const taskProject = seededProjects.find((p) => p.title === 'Task Management Application');
    await UserProject.create({
      userId: demoUser._id,
      projectId: taskProject._id,
      status: 'in_progress',
      completedMilestones: ['task-ms-1', 'task-ms-2'],
      githubUrl: 'https://github.com/alexdev/skillpath-task-app',
      liveDemoUrl: 'https://skillpath-tasks.web.app',
      notes: 'Implemented SQLite repository and models. Working on Riverpod state provider next.',
      userResumeBullets: [
        'Architected and developed Task Management Application utilizing Flutter, Riverpod, SQLite / Hive, Material 3.',
        'Implemented persistent SQLite database layer with full CRUD operations and local caching.'
      ],
      startedAt: pastDate
    });

    // Seed Demo User Activity Logs
    const day1 = new Date();
    day1.setDate(day1.getDate() - 3);
    const day2 = new Date();
    day2.setDate(day2.getDate() - 2);
    const day3 = new Date();
    day3.setDate(day3.getDate() - 1);
    const today = new Date();

    await ActivityLog.create([
      { userId: demoUser._id, activityType: 'topic_completed', details: { topicId: 'sde-prog-fund' }, timestamp: day1 },
      { userId: demoUser._id, activityType: 'dsa_solved', details: { title: 'Two Sum', topic: 'Arrays', difficulty: 'Easy' }, timestamp: day2 },
      { userId: demoUser._id, activityType: 'project_milestone', details: { milestoneId: 'task-ms-1', projectTitle: 'Task Management Application' }, timestamp: day3 },
      { userId: demoUser._id, activityType: 'dsa_solved', details: { title: 'Valid Anagram', topic: 'Strings', difficulty: 'Easy' }, timestamp: today }
    ]);

    console.log('Seeding completed successfully!');
    console.log('==============================================');
    console.log('Demo Credentials:');
    console.log('Email: demo@skillpath.dev');
    console.log('Password: Password123!');
    console.log('==============================================');
    process.exit(0);
  } catch (error) {
    console.error('Seeding Error:', error);
    process.exit(1);
  }
};

seedData();
