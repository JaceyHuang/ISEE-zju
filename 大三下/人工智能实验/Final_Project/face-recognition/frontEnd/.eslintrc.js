module.exports = {
  env: { browser: true },
  extends: ['plugin:react/recommended'],
  parserOptions: {
    ecmaFeatures: { jsx: true },
    ecmaVersion: 12,
    sourceType: 'module',
  },
  settings: { react: { version: 'detect' } },
  plugins: ['react', 'import'],
  rules: {
    'no-unused-vars': 'off',
    'no-invalid-this': 'off',
    'require-jsdoc': 'off',
    'react/prop-types': 'off',
    'react/display-name': 'off',
    'max-len': [
      'warn',
      80,
      {
        ignorePattern: '^import\\s.+\\sfrom\\s.+;$',
        ignoreUrls: true,
      },
    ],
    'quote-props': ['warn', 'consistent-as-needed'],
    'indent': ['warn', 2, { SwitchCase: 1 }],
    'react/jsx-indent': ['warn', 2],
    'react/jsx-indent-props': ['warn', 2],
    'quotes': ['warn', 'single'],
    'semi': ['warn', 'always'],
    'object-curly-newline': ['warn', { multiline: true }],
    'object-curly-spacing': ['warn', 'always'],
    'comma-spacing': ['warn', { before: false, after: true }],
    'no-multi-spaces': ['warn'],
    'import/order': [
      'warn', {
        groups: [
          'index',
          'sibling',
          'parent',
          'internal',
          'external',
          'builtin',
          'object',
          'type'
        ]
      }
    ],
    'no-multiple-empty-lines': ['warn', { max: 1, maxEOF: 1, maxBOF: 0 }],
    'eol-last': 1,
    'react/jsx-first-prop-new-line': ['warn', 'multiline'],
    'react/jsx-max-props-per-line': ['warn', { maximum: 1, when: 'multiline' }],
    'array-element-newline': ['warn', 'consistent'],
    'jsx-quotes': ['warn', 'prefer-double'],
    'array-bracket-newline': ['warn', { multiline: true }],
    'no-trailing-spaces': 'warn',
    'space-in-parens': ['warn', 'never'],
  },
};
