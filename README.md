# Installation

1. Navigate to your app directory where you want to include this style configuration.

   ```bash
   cd my-app
   ```

2. Run this command inside your app's root directory. Note: this command executes the `eslint-prettier-config.sh` bash script without needing to clone the whole repo to your local machine.

   ```bash
   exec 3<&1;bash <&3 <(curl https://raw.githubusercontent.com/twistedTongues/eslint-prettier-airbnb-react/master/eslint-prettier-config.sh 2> /dev/null)
   ```

3. Make selections for your preference of package manager (npm or yarn), file format (.js or .json), max-line size, and trailing commas (none, es5, all).

4. Look in your project's root directory and notice the two newly added/updated config files:
   - `.eslintrc.js` (or `.eslintrc.json`)
   - `.prettierrc.js` (or `.prettierrc.json`)

# Packages

### Main Packages

1. [ESlint](https://eslint.org/)
2. [Prettier](https://prettier.io/)

### Airbnb Configuration

1. [eslint-config-airbnb](https://www.npmjs.com/package/eslint-config-airbnb)
   - This package provides Airbnb's .eslintrc as an extensible shared config.
2. [eslint-plugin-jsx-a11y](https://github.com/evcohen/eslint-plugin-jsx-a11y) (Peer Dependency)
   - Static AST checker for accessibility rules on JSX elements.
3. [eslint-plugin-react](https://github.com/yannickcr/eslint-plugin-react) (Peer Dependency)
   - React specific linting rules for ESLint
4. [eslint-plugin-import](https://www.npmjs.com/package/eslint-plugin-import) (Peer Dependency)
   - Support linting of ES2015+ (ES6+) import/export syntax, and prevent issues with misspelling of file paths and import names.
5. [babel-eslint](https://github.com/babel/babel-eslint)
   - A wrapper for Babel's parser used for ESLint.
   - We decided to include this since [Airbnb Style Guide uses Babel](https://github.com/airbnb/javascript#airbnb-javascript-style-guide-).

### ESlint, Prettier Integration

1. [eslint-plugin-prettier](https://github.com/prettier/eslint-plugin-prettier)
   - Runs Prettier as an ESLint rule and reports differences as individual ESLint issues.
2. [eslint-config-prettier](https://github.com/prettier/eslint-config-prettier)
   - Turns off all rules that are unnecessary or might conflict with Prettier.
