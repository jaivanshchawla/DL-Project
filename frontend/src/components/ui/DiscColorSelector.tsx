import React, { useState } from 'react';
import {
  DISC_COLOR_OPTIONS,
  buildDiscGradient,
  getDiscColorOption,
  normalizeDiscColorSelection,
  type DiscColorId,
  type DiscColorSelection
} from '../../utils/discColors';

interface DiscColorSelectorProps {
  selection: DiscColorSelection;
  onChange: (selection: DiscColorSelection) => void;
  variant?: 'dark' | 'light';
  title?: string;
  description?: string;
  collapsible?: boolean;
  defaultExpanded?: boolean;
}

const DiscColorSelector: React.FC<DiscColorSelectorProps> = ({
  selection,
  onChange,
  variant = 'dark',
  title = 'Disc Colors',
  description = 'Choose your disc and the AI disc. Picking the same color swaps the two.',
  collapsible = false,
  defaultExpanded = true
}) => {
  const normalized = normalizeDiscColorSelection(selection);
  const playerDisc = getDiscColorOption(normalized.player);
  const aiDisc = getDiscColorOption(normalized.ai);
  const [isExpanded, setIsExpanded] = useState(defaultExpanded);

  const surface =
    variant === 'dark'
      ? {
          panel: 'rgba(8, 15, 35, 0.54)',
          border: 'rgba(255, 255, 255, 0.16)',
          text: '#f8fafc',
          muted: 'rgba(226, 232, 240, 0.78)',
          chip: 'rgba(255, 255, 255, 0.08)'
        }
      : {
          panel: 'rgba(255, 255, 255, 0.92)',
          border: 'rgba(59, 130, 246, 0.18)',
          text: '#0f172a',
          muted: '#475569',
          chip: 'rgba(59, 130, 246, 0.06)'
        };

  const applyChange = (target: 'player' | 'ai', colorId: DiscColorId) => {
    const nextSelection =
      target === 'player'
        ? {
            player: colorId,
            ai: colorId === normalized.ai ? normalized.player : normalized.ai
          }
        : {
            player: colorId === normalized.player ? normalized.ai : normalized.player,
            ai: colorId
          };

    onChange(normalizeDiscColorSelection(nextSelection));
  };

  const showExpandedContent = !collapsible || isExpanded;

  const renderColorRow = (target: 'player' | 'ai', activeColor: DiscColorId) => (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, minmax(0, 1fr))', gap: 10 }}>
      {DISC_COLOR_OPTIONS.map(option => {
        const isSelected = option.id === activeColor;
        return (
          <button
            key={`${target}-${option.id}`}
            type="button"
            onClick={() => applyChange(target, option.id)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              padding: '10px 12px',
              borderRadius: 14,
              border: isSelected ? `2px solid ${option.base}` : `1px solid ${surface.border}`,
              background: isSelected ? `${surface.chip}` : 'transparent',
              color: surface.text,
              cursor: 'pointer',
              transition: 'transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease',
              boxShadow: isSelected ? `0 10px 24px ${option.glow}` : 'none'
            }}
          >
            <span
              style={{
                width: 18,
                height: 18,
                borderRadius: '50%',
                background: buildDiscGradient(option),
                boxShadow: `0 0 0 1px rgba(255,255,255,0.35), 0 6px 16px ${option.glow}`,
                flexShrink: 0
              }}
            />
            <span style={{ fontSize: 13, fontWeight: 700, letterSpacing: 0.2 }}>{option.name}</span>
          </button>
        );
      })}
    </div>
  );

  return (
    <div
      style={{
        width: '100%',
        background: surface.panel,
        border: `1px solid ${surface.border}`,
        borderRadius: 24,
        padding: 20,
        boxShadow: variant === 'dark' ? '0 24px 60px rgba(2, 6, 23, 0.22)' : '0 18px 40px rgba(59, 130, 246, 0.12)',
        backdropFilter: 'blur(18px)'
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 16, marginBottom: 18 }}>
        <div>
          <div style={{ fontSize: 18, fontWeight: 800, color: surface.text }}>{title}</div>
          <div style={{ marginTop: 6, fontSize: 13, lineHeight: 1.5, color: surface.muted }}>{description}</div>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          {[playerDisc, aiDisc].map((option, index) => (
            <span
              key={`${option.id}-${index}`}
              style={{
                width: 22,
                height: 22,
                borderRadius: '50%',
                background: buildDiscGradient(option),
                boxShadow: `0 10px 24px ${option.glow}`
              }}
            />
          ))}
        </div>
      </div>

      {collapsible && (
        <button
          type="button"
          onClick={() => setIsExpanded(prev => !prev)}
          style={{
            width: '100%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: 16,
            border: `1px solid ${surface.border}`,
            background: variant === 'dark' ? 'rgba(255, 255, 255, 0.06)' : 'rgba(248, 250, 252, 0.95)',
            borderRadius: 18,
            padding: '14px 16px',
            color: surface.text,
            cursor: 'pointer',
            marginBottom: showExpandedContent ? 18 : 0,
            boxShadow: showExpandedContent ? 'none' : `0 16px 36px ${variant === 'dark' ? 'rgba(15, 23, 42, 0.22)' : 'rgba(59, 130, 246, 0.10)'}`
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, flexWrap: 'wrap' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span
                style={{
                  width: 18,
                  height: 18,
                  borderRadius: '50%',
                  background: buildDiscGradient(playerDisc),
                  boxShadow: `0 10px 24px ${playerDisc.glow}`
                }}
              />
              <span style={{ fontSize: 13, fontWeight: 800, color: surface.text }}>You</span>
              <span style={{ fontSize: 13, color: playerDisc.base, fontWeight: 700 }}>{playerDisc.name}</span>
            </div>
            <div style={{ width: 1, height: 18, background: surface.border }} />
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span
                style={{
                  width: 18,
                  height: 18,
                  borderRadius: '50%',
                  background: buildDiscGradient(aiDisc),
                  boxShadow: `0 10px 24px ${aiDisc.glow}`
                }}
              />
              <span style={{ fontSize: 13, fontWeight: 800, color: surface.text }}>AI</span>
              <span style={{ fontSize: 13, color: aiDisc.base, fontWeight: 700 }}>{aiDisc.name}</span>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexShrink: 0 }}>
            <span style={{ fontSize: 12, fontWeight: 800, letterSpacing: 0.5, color: surface.muted }}>
              {showExpandedContent ? 'Hide Options' : 'Customize'}
            </span>
            <span
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                width: 28,
                height: 28,
                borderRadius: '50%',
                border: `1px solid ${surface.border}`,
                background: surface.chip,
                transform: showExpandedContent ? 'rotate(180deg)' : 'rotate(0deg)',
                transition: 'transform 0.18s ease'
              }}
            >
              ˅
            </span>
          </div>
        </button>
      )}

      {showExpandedContent && (
      <div style={{ display: 'grid', gap: 18 }}>
        <div
          style={{
            padding: 14,
            borderRadius: 18,
            border: `1px solid ${surface.border}`,
            background: variant === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 'rgba(248, 250, 252, 0.9)'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, marginBottom: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <span
                style={{
                  width: 20,
                  height: 20,
                  borderRadius: '50%',
                  background: buildDiscGradient(playerDisc),
                  boxShadow: `0 10px 24px ${playerDisc.glow}`
                }}
              />
              <span style={{ color: surface.text, fontWeight: 700 }}>Your Disc</span>
            </div>
            <span style={{ color: playerDisc.base, fontSize: 12, fontWeight: 800, letterSpacing: 0.5 }}>{playerDisc.name}</span>
          </div>
          {renderColorRow('player', normalized.player)}
        </div>

        <div
          style={{
            padding: 14,
            borderRadius: 18,
            border: `1px solid ${surface.border}`,
            background: variant === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 'rgba(248, 250, 252, 0.9)'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, marginBottom: 12 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <span
                style={{
                  width: 20,
                  height: 20,
                  borderRadius: '50%',
                  background: buildDiscGradient(aiDisc),
                  boxShadow: `0 10px 24px ${aiDisc.glow}`
                }}
              />
              <span style={{ color: surface.text, fontWeight: 700 }}>AI Disc</span>
            </div>
            <span style={{ color: aiDisc.base, fontSize: 12, fontWeight: 800, letterSpacing: 0.5 }}>{aiDisc.name}</span>
          </div>
          {renderColorRow('ai', normalized.ai)}
        </div>
      </div>
      )}
    </div>
  );
};

export default DiscColorSelector;
