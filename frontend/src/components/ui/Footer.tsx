import React from 'react';
import { motion, useReducedMotion } from 'framer-motion';
import { HoverCard, Portal } from '@ark-ui/react';
import './FooterHoverCard.css';

const Footer: React.FC = () => {
  const prefersReducedMotion = useReducedMotion();
  const floatingIcons = ['⚛️', '🚀', '🎮'];

  return (
    <motion.footer
      className="fixed bottom-0 left-0 right-0 bg-white bg-opacity-10 backdrop-blur-md py-4 px-8 border-t border-white border-opacity-20 footer-shell"
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ delay: 0.35, duration: 0.65, ease: [0.22, 1, 0.36, 1] }}
    >
      <div className="flex items-center justify-center">
        <motion.div
          className="flex items-center gap-3 footer-content"
          whileHover={prefersReducedMotion ? undefined : { scale: 1.02, y: -1 }}
          transition={{ type: 'spring', stiffness: 240, damping: 24, mass: 0.8 }}
        >
          <motion.div
            className="text-2xl footer-glyph"
            animate={prefersReducedMotion ? undefined : { rotate: [0, 8, -6, 0], y: [0, -2, 0] }}
            transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
          >
            {'\u{1F4BB}'}
          </motion.div>

          <motion.h3
            className="text-lg font-semibold text-white opacity-90"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.5, duration: 0.45 }}
          >
            Built with {'\u2764\uFE0F'} by
          </motion.h3>

          <HoverCard.Root openDelay={120} closeDelay={150} positioning={{ placement: 'top', gutter: 16 }}>
            <HoverCard.Trigger asChild>
              <motion.button
                type="button"
                className="footer-profile-trigger text-xl font-bold bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent cursor-pointer no-underline"
                initial={{ opacity: 0, scale: 0.5 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.65, duration: 0.45, type: 'spring', stiffness: 220, damping: 22 }}
                whileHover={prefersReducedMotion ? undefined : { scale: 1.04, y: -1 }}
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

          <motion.div
            className="text-2xl footer-glyph"
            animate={prefersReducedMotion ? undefined : { scale: [1, 1.05, 1], y: [0, -3, 0] }}
            transition={{ duration: 3.8, repeat: Infinity, ease: 'easeInOut' }}
          >
            {'\u{1F9E0}'}
          </motion.div>
        </motion.div>

        <div className="absolute right-8 hidden gap-4 md:flex">
          {floatingIcons.map((icon, index) => (
            <motion.span
              key={icon}
              className="text-lg opacity-40 footer-tech-icon"
              animate={prefersReducedMotion ? undefined : { y: [0, -6, 0], rotate: [0, 4, -4, 0] }}
              transition={{
                duration: 3.4,
                delay: index * 0.28,
                repeat: Infinity,
                ease: 'easeInOut'
              }}
            >
              {icon}
            </motion.span>
          ))}
        </div>
      </div>

      <motion.p
        className="text-center text-xs text-white opacity-40 mt-2"
        initial={{ opacity: 0 }}
        animate={{ opacity: 0.4 }}
        transition={{ delay: 0.85 }}
      >
        {'\u00A9'} 2025 Connect Four AI - Enterprise Edition
      </motion.p>
    </motion.footer>
  );
};

export default Footer;
