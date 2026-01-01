// =============================================================================
// JavaScript/TypeScript Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

// Hex strings (most common in JS/TS)
const primaryColor = "#FF5500";
const secondaryColor = "#3498db";
const withAlpha = "#FF550080";

// Theme object with hex colors
const theme = {
  colors: {
    primary: "#e74c3c",
    secondary: "#3498db",
    success: "#2ecc71",
    warning: "#f39c12",
    danger: "#e74c3c",
    info: "#17a2b8",
    light: "#f8f9fa",
    dark: "#343a40",
  },
  shadows: {
    small: "0 2px 4px rgba(0, 0, 0, 0.1)",
    medium: "0 4px 8px rgba(0, 0, 0, 0.2)",
    large: "0 8px 16px rgba(0, 0, 0, 0.3)",
  },
};

// CSS-in-JS (styled-components, emotion, etc.)
const styles = {
  container: {
    backgroundColor: "#1a1a2e",
    color: "#ffffff",
    borderColor: rgb(52, 152, 219),
  },
  button: {
    background: "linear-gradient(135deg, #667eea, #764ba2)",
    boxShadow: "0 4px 15px rgba(102, 126, 234, 0.4)",
  },
  overlay: {
    backgroundColor: rgba(0, 0, 0, 0.75),
  },
};

// React component with inline styles
function ColorCard({ color }: { color: string }) {
  return (
    <div
      style={{
        backgroundColor: "#f5f5f5",
        borderLeft: `4px solid ${color}`,
        boxShadow: "0 2px 8px rgba(0, 0, 0, 0.15)",
      }}
    >
      <span style={{ color: "#333333" }}>Color: {color}</span>
    </div>
  );
}

// Tailwind-style config
const tailwindColors = {
  slate: {
    50: "#f8fafc",
    100: "#f1f5f9",
    200: "#e2e8f0",
    300: "#cbd5e1",
    400: "#94a3b8",
    500: "#64748b",
    600: "#475569",
    700: "#334155",
    800: "#1e293b",
    900: "#0f172a",
  },
  emerald: {
    400: "#34d399",
    500: "#10b981",
    600: "#059669",
  },
};

// Canvas/WebGL numeric hex
const canvasColors = {
  red: 0xff0000,
  green: 0x00ff00,
  blue: 0x0000ff,
  white: 0xffffff,
  black: 0x000000,
};

export { theme, styles, tailwindColors, canvasColors };
