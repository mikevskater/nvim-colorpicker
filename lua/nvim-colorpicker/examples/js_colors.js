// ============================================================================
// JavaScript Colors Test File - nvim-colorpicker
// ============================================================================
//
// TEST INSTRUCTIONS:
// 1. Run :ColorHighlight to see inline color previews
// 2. Position cursor on any color value
// 3. Run :ColorPickerAtCursor to open picker and replace
// 4. Run :ColorConvert hsl to convert hex to hsl
//
// ============================================================================

// ----------------------------------------------------------------------------
// Section 1: Basic Color Constants
// Test: Hex colors in JS strings
// ----------------------------------------------------------------------------

const colors = {
  primary: '#3498DB',
  secondary: '#2ECC71',
  accent: '#E74C3C',
  warning: '#F1C40F',
  info: '#17A2B8',
  dark: '#343A40',
  light: '#F8F9FA',
};

// Single quotes vs double quotes
const red = '#FF0000';
const green = "#00FF00";
const blue = `#0000FF`;

// ----------------------------------------------------------------------------
// Section 2: RGB/RGBA in JavaScript
// Test: CSS color functions in JS strings
// ----------------------------------------------------------------------------

const rgbColors = {
  transparent: 'rgba(0, 0, 0, 0)',
  semiTransparent: 'rgba(255, 255, 255, 0.5)',
  solid: 'rgb(52, 152, 219)',
  withAlpha: 'rgba(46, 204, 113, 0.8)',
};

// Template literals with colors
const dynamicColor = `rgba(${255}, ${85}, ${0}, ${0.5})`;

// ----------------------------------------------------------------------------
// Section 3: HSL Colors
// Test: HSL format in JS
// ----------------------------------------------------------------------------

const hslColors = {
  primary: 'hsl(204, 70%, 53%)',
  secondary: 'hsl(145, 63%, 49%)',
  accent: 'hsl(6, 78%, 57%)',
  muted: 'hsla(0, 0%, 50%, 0.5)',
};

// ----------------------------------------------------------------------------
// Section 4: CSS-in-JS (Styled Components / Emotion)
// Test: Colors in template literal CSS
// ----------------------------------------------------------------------------

const Button = styled.button`
  background-color: #3498DB;
  color: #FFFFFF;
  border: 2px solid #2980B9;

  &:hover {
    background-color: #2980B9;
    border-color: #1F618D;
  }

  &:active {
    background-color: #1F618D;
  }
`;

const Card = styled.div`
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
`;

// ----------------------------------------------------------------------------
// Section 5: React Inline Styles
// Test: Colors in style objects
// ----------------------------------------------------------------------------

const styles = {
  container: {
    backgroundColor: '#F5F5F5',
    borderColor: '#DDDDDD',
    color: '#333333',
  },
  header: {
    backgroundColor: '#2C3E50',
    color: '#ECF0F1',
    borderBottom: '3px solid #3498DB',
  },
  button: {
    backgroundColor: '#27AE60',
    color: '#FFFFFF',
    border: 'none',
  },
};

function Component() {
  return (
    <div style={{ backgroundColor: '#1E1E1E', color: '#D4D4D4' }}>
      <h1 style={{ color: '#569CD6' }}>Title</h1>
      <p style={{ color: '#6A9955' }}>Description</p>
    </div>
  );
}

// ----------------------------------------------------------------------------
// Section 6: Theme Configuration
// Test: Nested color objects
// ----------------------------------------------------------------------------

const theme = {
  colors: {
    brand: {
      primary: '#0066CC',
      secondary: '#00994D',
      tertiary: '#CC6600',
    },
    ui: {
      background: '#FFFFFF',
      foreground: '#1A1A1A',
      border: '#E5E5E5',
      hover: '#F0F0F0',
      active: '#E0E0E0',
      disabled: '#CCCCCC',
    },
    text: {
      primary: '#1A1A1A',
      secondary: '#666666',
      muted: '#999999',
      inverse: '#FFFFFF',
    },
    status: {
      success: '#28A745',
      warning: '#FFC107',
      error: '#DC3545',
      info: '#17A2B8',
    },
  },
  shadows: {
    small: '0 1px 3px rgba(0, 0, 0, 0.12)',
    medium: '0 4px 6px rgba(0, 0, 0, 0.1)',
    large: '0 10px 20px rgba(0, 0, 0, 0.15)',
  },
};

// ----------------------------------------------------------------------------
// Section 7: Tailwind Config Colors
// Test: Tailwind-style color configuration
// ----------------------------------------------------------------------------

const tailwindConfig = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#EBF5FF',
          100: '#E1EFFE',
          200: '#C3DDFD',
          300: '#A4CAFE',
          400: '#76A9FA',
          500: '#3F83F8',
          600: '#1C64F2',
          700: '#1A56DB',
          800: '#1E429F',
          900: '#233876',
        },
        accent: {
          light: '#FDE68A',
          DEFAULT: '#F59E0B',
          dark: '#B45309',
        },
      },
    },
  },
};

// ----------------------------------------------------------------------------
// Section 8: Canvas/WebGL Colors
// Test: Colors in drawing contexts
// ----------------------------------------------------------------------------

function drawCanvas(ctx) {
  ctx.fillStyle = '#FF5500';
  ctx.strokeStyle = '#3498DB';
  ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';

  // Gradient
  const gradient = ctx.createLinearGradient(0, 0, 200, 0);
  gradient.addColorStop(0, '#FF0000');
  gradient.addColorStop(0.5, '#00FF00');
  gradient.addColorStop(1, '#0000FF');
}

// ----------------------------------------------------------------------------
// Section 9: Chart.js / D3 Colors
// Test: Colors in data visualization
// ----------------------------------------------------------------------------

const chartConfig = {
  datasets: [{
    label: 'Sales',
    backgroundColor: [
      '#FF6384',
      '#36A2EB',
      '#FFCE56',
      '#4BC0C0',
      '#9966FF',
      '#FF9F40',
    ],
    borderColor: '#FFFFFF',
    borderWidth: 2,
  }],
};

const d3Colors = [
  '#1f77b4', // Blue
  '#ff7f0e', // Orange
  '#2ca02c', // Green
  '#d62728', // Red
  '#9467bd', // Purple
  '#8c564b', // Brown
  '#e377c2', // Pink
  '#7f7f7f', // Gray
  '#bcbd22', // Yellow-green
  '#17becf', // Cyan
];

// ----------------------------------------------------------------------------
// Section 10: Color Manipulation
// Test: Colors in utility functions
// ----------------------------------------------------------------------------

function hexToRgb(hex) {
  // Input: #FF5500
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16),
  } : null;
}

function lightenColor(color, percent) {
  // Lighten #3498DB by 20%
  // Result should be lighter
  return adjustBrightness(color, percent);
}

// Color constants for animation
const ANIMATION_COLORS = {
  start: '#FF0000',
  middle: '#FFFF00',
  end: '#00FF00',
};

// Export colors for use in other modules
export const brandColors = {
  primary: '#0066FF',
  secondary: '#00CC99',
  accent: '#FF6600',
};

export default colors;
