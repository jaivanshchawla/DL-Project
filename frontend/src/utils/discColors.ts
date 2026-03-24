export type DiscColorId =
  | 'crimson'
  | 'amber'
  | 'azure'
  | 'emerald'
  | 'violet'
  | 'coral';

export interface DiscColorOption {
  id: DiscColorId;
  name: string;
  base: string;
  edge: string;
  glow: string;
  text: string;
}

export interface DiscColorSelection {
  player: DiscColorId;
  ai: DiscColorId;
}

export const DISC_COLOR_STORAGE_KEY = 'connect4DiscColors';
export const DISC_COLOR_EVENT = 'connect4:disc-colors-changed';

export const DISC_COLOR_OPTIONS: DiscColorOption[] = [
  {
    id: 'crimson',
    name: 'Crimson',
    base: '#ef4444',
    edge: '#991b1b',
    glow: 'rgba(239, 68, 68, 0.42)',
    text: '#fee2e2'
  },
  {
    id: 'amber',
    name: 'Amber',
    base: '#fbbf24',
    edge: '#b45309',
    glow: 'rgba(251, 191, 36, 0.42)',
    text: '#fef3c7'
  },
  {
    id: 'azure',
    name: 'Azure',
    base: '#38bdf8',
    edge: '#075985',
    glow: 'rgba(56, 189, 248, 0.42)',
    text: '#e0f2fe'
  },
  {
    id: 'emerald',
    name: 'Emerald',
    base: '#34d399',
    edge: '#065f46',
    glow: 'rgba(52, 211, 153, 0.42)',
    text: '#d1fae5'
  },
  {
    id: 'violet',
    name: 'Violet',
    base: '#a78bfa',
    edge: '#5b21b6',
    glow: 'rgba(167, 139, 250, 0.42)',
    text: '#ede9fe'
  },
  {
    id: 'coral',
    name: 'Coral',
    base: '#fb7185',
    edge: '#9f1239',
    glow: 'rgba(251, 113, 133, 0.42)',
    text: '#ffe4e6'
  }
];

export const DEFAULT_DISC_COLOR_SELECTION: DiscColorSelection = {
  player: 'crimson',
  ai: 'amber'
};

export const getDiscColorOption = (id: DiscColorId): DiscColorOption =>
  DISC_COLOR_OPTIONS.find(option => option.id === id) ||
  DISC_COLOR_OPTIONS[0];

export const normalizeDiscColorSelection = (
  selection?: Partial<DiscColorSelection> | null
): DiscColorSelection => {
  const player = selection?.player || DEFAULT_DISC_COLOR_SELECTION.player;
  let ai = selection?.ai || DEFAULT_DISC_COLOR_SELECTION.ai;

  if (player === ai) {
    ai = DISC_COLOR_OPTIONS.find(option => option.id !== player)?.id || DEFAULT_DISC_COLOR_SELECTION.ai;
  }

  return { player, ai };
};

export const loadDiscColorSelection = (): DiscColorSelection => {
  if (typeof window === 'undefined') {
    return DEFAULT_DISC_COLOR_SELECTION;
  }

  try {
    const stored = window.localStorage.getItem(DISC_COLOR_STORAGE_KEY);
    if (!stored) {
      return DEFAULT_DISC_COLOR_SELECTION;
    }

    return normalizeDiscColorSelection(JSON.parse(stored));
  } catch {
    return DEFAULT_DISC_COLOR_SELECTION;
  }
};

export const saveDiscColorSelection = (selection: DiscColorSelection): DiscColorSelection => {
  const normalized = normalizeDiscColorSelection(selection);

  if (typeof window !== 'undefined') {
    window.localStorage.setItem(DISC_COLOR_STORAGE_KEY, JSON.stringify(normalized));
    window.dispatchEvent(
      new CustomEvent(DISC_COLOR_EVENT, {
        detail: normalized
      })
    );
  }

  return normalized;
};

export const buildDiscGradient = (
  option: Pick<DiscColorOption, 'base' | 'edge' | 'glow' | 'text'>
): string =>
  `radial-gradient(circle at 30% 28%, rgba(255,255,255,0.95) 0%, ${option.text} 12%, ${option.base} 42%, ${option.edge} 100%)`;
