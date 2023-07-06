/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./*.{html,js}"
  ],
  theme: {
    extend: {
      keyframes: {
        bouncyuwu: {
          '0%, 100%': {transform: 'translateY(6rem)'},
          '50%': {transform: 'translateY(5.5rem)'}
        },
        clipboarduww: {
          '0%, 100%': {color: '#0369a1'},
          '50%': {color: '#38bdf8'}
        }
      },
      colors: {
        iframe_primary: '#141114',
        iframe_codeblock: '#1E1A1E',
      },
      animation: {
        bouncyuwu: 'bouncyuwu 0.7s ease-in-out 3',
        clipboarduwu: 'clipboarduww 0.3s ease-in-out 1',
        customspin: 'spin 2s ease-in-out infinite',
      },
      fontFamily: {
        'poppins': 'Poppins, sans-serif'
      },
    },
  },
  plugins: [],
}

