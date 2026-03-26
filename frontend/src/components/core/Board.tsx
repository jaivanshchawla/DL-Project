import React, { useState, useEffect, useRef } from 'react';
import { buildDiscGradient } from '../../utils/discColors';

export type CellValue = 'Empty' | 'Red' | 'Yellow';

interface BoardProps {
  /** 6×7 matrix representing the current board state */
  board?: CellValue[][];
  /** Called with the column index when a slot is clicked */
  onDrop: (column: number) => void;
  /** Optional list of [row, col] pairs to highlight the winning line */
  winningLine?: [number, number][];
  /** Visual color theme for logical Red and Yellow discs */
  discTheme?: {
    Red: { base: string; edge: string; glow: string; text: string };
    Yellow: { base: string; edge: string; glow: string; text: string };
  };
}

// Grid container style
const gridStyle: React.CSSProperties = {
  display: 'grid',
  gridTemplateRows: 'repeat(6, 1fr)',
  gridTemplateColumns: 'repeat(7, 1fr)',
  gap: 'clamp(4px, 1vw, 12px)',
  background: 'transparent',
  padding: 'clamp(8px, 2vw, 16px)',
  borderRadius: '8px',
  width: '100%',
  maxWidth: '644px', // 7 * 80px + 6 * 12px + 2 * 16px
  aspectRatio: '7 / 6',
};

// Individual slot style (ring)
const cellStyle: React.CSSProperties = {
  width: '100%',
  aspectRatio: '1',
  borderRadius: '50%',
  border: 'clamp(3px, 0.5vw, 6px) solid #26418f',
  background: '#1e2a47',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  transition: 'background 0.2s ease, transform 0.2s ease',
  cursor: 'pointer',
  position: 'relative',
};

// Disc style matching slot interior
const discStyle = (
  option: { base: string; edge: string; glow: string; text: string }
): React.CSSProperties => ({
  width: '85%',
  height: '85%',
  borderRadius: '50%',
  background: buildDiscGradient(option),
  boxShadow: `inset 0 1px 3px rgba(255,255,255,0.42), 0 0 20px ${option.glow}`,
  border: `1px solid ${option.edge}`,
  pointerEvents: 'none',
  transform: 'translateZ(0)',
  willChange: 'transform',
});

/**
 * Board renders the 6×7 Connect Four grid and discs,
 * using local state synced from the `board` prop.
 */
const Board: React.FC<BoardProps> = ({
  board,
  onDrop,
  winningLine = [],
  discTheme = {
    Red: {
      base: '#ef4444',
      edge: '#991b1b',
      glow: 'rgba(239, 68, 68, 0.42)',
      text: '#fee2e2'
    },
    Yellow: {
      base: '#fbbf24',
      edge: '#b45309',
      glow: 'rgba(251, 191, 36, 0.42)',
      text: '#fef3c7'
    }
  }
}) => {
  // Local state for the board, initialized from props
  const [localBoard, setLocalBoard] = useState<CellValue[][]>(
    board ?? Array.from({ length: 6 }, () => Array(7).fill('Empty'))
  );

  // Animate disc dropping when the board prop changes
  const prevBoardRef = useRef<CellValue[][]>(localBoard);
  const [hoveredCol, setHoveredCol] = useState<number | null>(null);
  const [dropCoord, setDropCoord] = useState<{ row: number; col: number } | null>(null);
  const [bounceCoord, setBounceCoord] = useState<{ row: number; col: number } | null>(null);
  const hoverFrameRef = useRef<number | null>(null);
  const dropTimeoutRef = useRef<number | null>(null);
  const bounceStartTimeoutRef = useRef<number | null>(null);
  const bounceTimeoutRef = useRef<number | null>(null);

  const scheduleHoveredCol = (nextCol: number | null) => {
    if (hoverFrameRef.current !== null) {
      cancelAnimationFrame(hoverFrameRef.current);
    }

    hoverFrameRef.current = requestAnimationFrame(() => {
      setHoveredCol((current) => (current === nextCol ? current : nextCol));
      hoverFrameRef.current = null;
    });
  };

  useEffect(() => {
    if (!board) return;
    const prevBoard = prevBoardRef.current;
    // Find the new disc position
    let newPos: { row: number; col: number; color: CellValue } | null = null;
    for (let r = 0; r < prevBoard.length; r++) {
      for (let c = 0; c < prevBoard[r].length; c++) {
        if (prevBoard[r][c] === 'Empty' && board[r][c] !== 'Empty') {
          newPos = { row: r, col: c, color: board[r][c] };
          break;
        }
      }
      if (newPos) break;
    }
    if (!newPos) {
      setLocalBoard(board);
      prevBoardRef.current = board;
      return;
    }
    const { row: targetRow, col } = newPos;
    // Immediately update board to final state and update prevBoard
    setLocalBoard(board);
    prevBoardRef.current = board;
    // Trigger drop animation
    setDropCoord({ row: targetRow, col });
    if (dropTimeoutRef.current) {
      clearTimeout(dropTimeoutRef.current);
    }
    if (bounceStartTimeoutRef.current) {
      clearTimeout(bounceStartTimeoutRef.current);
    }
    if (bounceTimeoutRef.current) {
      clearTimeout(bounceTimeoutRef.current);
    }
    dropTimeoutRef.current = window.setTimeout(() => setDropCoord(null), 320);
    bounceStartTimeoutRef.current = window.setTimeout(() => {
      setBounceCoord({ row: targetRow, col });
      bounceTimeoutRef.current = window.setTimeout(() => setBounceCoord(null), 220);
    }, 300);
  }, [board]);

  useEffect(() => () => {
    if (hoverFrameRef.current !== null) {
      cancelAnimationFrame(hoverFrameRef.current);
    }
    if (dropTimeoutRef.current) {
      clearTimeout(dropTimeoutRef.current);
    }
    if (bounceStartTimeoutRef.current) {
      clearTimeout(bounceStartTimeoutRef.current);
    }
    if (bounceTimeoutRef.current) {
      clearTimeout(bounceTimeoutRef.current);
    }
  }, []);

  const displayBoard = localBoard;

  // helper to check if a cell is in the winning line
  const isWinningCell = (r: number, c: number) =>
    winningLine.some(([wr, wc]) => wr === r && wc === c);

  return (
    <div className="fade-in board-tilt"
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        marginTop: 'clamp(1rem, 3vh, 2rem)',
        width: '100%',
        paddingLeft: 'clamp(8px, 2vw, 24px)',
        paddingRight: 'clamp(8px, 2vw, 24px)',
      }}
    >
      <div className="board-bg board-float" style={gridStyle}>
        {displayBoard.map((row, rowIndex) =>
          row.map((cell, colIndex) => {
            const highlight = isWinningCell(rowIndex, colIndex);
            return (
              <div
                key={`${rowIndex}-${colIndex}`} className={cell === 'Empty' ? 'slot-pulse' : ''}
                style={{
                  ...cellStyle,
                  border: highlight ? '4px solid #06d6a0' : cellStyle.border,
                  background: displayBoard[rowIndex][colIndex] === 'Empty' && hoveredCol === colIndex ? 'rgba(255,255,255,0.2)' : cellStyle.background,
                  transform: displayBoard[rowIndex][colIndex] === 'Empty' && hoveredCol === colIndex ? 'translateZ(0) scale(1.03)' : 'translateZ(0) scale(1)',
                  boxShadow: highlight
                    ? '0 0 8px 4px rgba(6,214,160,0.7)'
                    : 'none',
                  animation: highlight ? 'glow 1s ease-in-out infinite alternate' : 'none',
                  willChange: 'transform',
                  cursor:
                    displayBoard[rowIndex][colIndex] === 'Empty'
                      ? 'pointer'
                      : 'default',
                }}
                onMouseEnter={() => scheduleHoveredCol(colIndex)}
                onMouseLeave={() => scheduleHoveredCol(null)}
                onClick={() => onDrop(colIndex)}
              >
                {cell !== 'Empty' && (
                  <div
                    style={{
                      ...discStyle(cell === 'Red' ? discTheme.Red : discTheme.Yellow),
                      animation: [
                        dropCoord?.row === rowIndex && dropCoord?.col === colIndex ? 'drop 0.32s cubic-bezier(0.22, 1, 0.36, 1)' : '',
                        bounceCoord?.row === rowIndex && bounceCoord?.col === colIndex ? 'bounce 0.22s ease-out' : ''
                      ].filter(anim => anim).join(', '),
                    }}
                  />
                )}
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};

export default Board;
