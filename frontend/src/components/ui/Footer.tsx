import React from 'react';
import { motion } from 'framer-motion';
import { HoverCard, Portal } from '@ark-ui/react';
import './FooterHoverCard.css';

const Footer: React.FC = () => {
  return (
    <motion.footer 
      className="fixed bottom-0 left-0 right-0 bg-white bg-opacity-10 backdrop-blur-md py-4 px-8 border-t border-white border-opacity-20"
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ delay: 0.5, duration: 0.8, ease: "easeOut" }}
    >
      <div className="flex items-center justify-center">
        <motion.div
          className="flex items-center gap-3"
          whileHover={{ scale: 1.05 }}
          transition={{ type: "spring", stiffness: 400, damping: 10 }}
        >
          {/* Animated code icon */}
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
            className="text-2xl"
          >
            💻
          </motion.div>
          
          {/* Main text with gradient */}
          <motion.h3 
            className="text-lg font-semibold text-white opacity-90"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.8, duration: 0.6 }}
          >
            Built with ❤️ by
          </motion.h3>
          
          {/* Name with profile hover card */}
          <HoverCard.Root openDelay={120} closeDelay={150} positioning={{ placement: 'top', gutter: 16 }}>
            <HoverCard.Trigger asChild>
              <motion.button
                type="button"
                className="footer-profile-trigger text-xl font-bold bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent cursor-pointer no-underline"
                initial={{ opacity: 0, scale: 0.5 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 1, duration: 0.5, type: "spring" }}
                whileHover={{
                  scale: 1.08,
                  textShadow: "0 0 20px rgba(34, 211, 238, 0.4)",
                }}
              >
                Jaivansh Chawla
              </motion.button>
            </HoverCard.Trigger>
            <Portal>
              <HoverCard.Positioner>
                <HoverCard.Content className="footer-hover-card">
                  <HoverCard.Arrow className="footer-hover-card-arrow">
                    <HoverCard.ArrowTip className="footer-hover-card-arrow-tip" />
                  </HoverCard.Arrow>
                  <div className="footer-hover-card-inner">
                    <div className="footer-hover-card-header">
                      <div className="footer-hover-card-avatar">JC</div>
                      <div className="footer-hover-card-heading">
                        <span className="footer-hover-card-badge">Project Owner</span>
                        <h4>Jaivansh Chawla</h4>
                        <p>Building Connect Four AI</p>
                      </div>
                    </div>

                    <p className="footer-hover-card-bio">
                      Driving the frontend polish, backend service integration, and gameplay tuning behind this project.
                    </p>

                    <div className="footer-hover-card-stats">
                      <div className="footer-hover-card-stat">
                        <span className="footer-hover-card-stat-value">UI</span>
                        <span className="footer-hover-card-stat-label">Product polish</span>
                      </div>
                      <div className="footer-hover-card-stat">
                        <span className="footer-hover-card-stat-value">API</span>
                        <span className="footer-hover-card-stat-label">Service wiring</span>
                      </div>
                      <div className="footer-hover-card-stat">
                        <span className="footer-hover-card-stat-value">AI</span>
                        <span className="footer-hover-card-stat-label">Gameplay tuning</span>
                      </div>
                    </div>

                    <div className="footer-hover-card-tags">
                      <span>React</span>
                      <span>Render</span>
                      <span>Vercel</span>
                      <span>Connect Four</span>
                    </div>
                  </div>
                </HoverCard.Content>
              </HoverCard.Positioner>
            </Portal>
          </HoverCard.Root>
          
          {/* Animated AI brain */}
          <motion.div
            className="text-2xl"
            animate={{ 
              scale: [1, 1.2, 1],
              filter: ["hue-rotate(0deg)", "hue-rotate(360deg)", "hue-rotate(0deg)"]
            }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
          >
            🦁
          </motion.div>
        </motion.div>
        
        {/* Floating tech icons */}
        <div className="absolute right-8 flex gap-4">
          {['⚛️', '🚀', '🎮', '🤖'].map((icon, index) => (
            <motion.span
              key={icon}
              className="text-lg opacity-40"
              animate={{ 
                y: [0, -10, 0],
                rotate: [0, 10, -10, 0]
              }}
              transition={{ 
                duration: 3,
                delay: index * 0.2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            >
              {icon}
            </motion.span>
          ))}
        </div>
      </div>
      
      {/* Subtle copyright text */}
      <motion.p 
        className="text-center text-xs text-white opacity-40 mt-2"
        initial={{ opacity: 0 }}
        animate={{ opacity: 0.4 }}
        transition={{ delay: 1.5 }}
      >
        © 2025 Connect Four AI - Enterprise Edition
      </motion.p>
    </motion.footer>
  );
};

export default Footer;
