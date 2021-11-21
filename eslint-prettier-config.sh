#!/bin/bash

# ----------------------
# Color Variables
# ----------------------
RED="\033[0;31m"
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color

# --------------------------------------
# Prompts for configuration preferences
# --------------------------------------

# Package Manager Prompt
echo
echo "Which package manager are you using?"
select package_command_choices in "Yarn" "npm" "Cancel"; do
  case $package_command_choices in
    Yarn ) pkg_cmd='yarn add'; break;;
    npm ) pkg_cmd='npm install'; break;;
    Cancel ) exit;;
  esac
done
echo

# Adding Typescript
echo
echo "Do you want to use Typescript in your project?"
select typescript_choice in "Yes" "No" "Cancel"; do
  case $typescript_choice in
    Yes ) break;;
    No ) break;;
    Cancel ) exit;;
  esac
done
echo

# Checks for existing tsconfig file
if [ -f "tsconfig.json" ]; then
  echo -e "${RED}Existing tsconfig file(s) found:${NC}"
  ls -a tsconfig* | xargs -n 1 basename
  echo
  echo
  echo
  skip_tsconfig_setup="false"
  read -p  "Write tsconfig.json (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping tsconfig ${NC}"
    skip_tsconfig_setup="true"
  fi
fi
finished=false

# File Format Prompt
echo "Which ESLint and Prettier configuration format do you prefer?"
select config_extension in ".js" ".json" "Cancel"; do
  case $config_extension in
    .js ) config_opening='module.exports = {'; break;;
    .json ) config_opening='{'; break;;
    Cancel ) exit;;
  esac
done
echo

# Checks for existing eslintrc files
if [ -f ".eslintrc.js" -o -f ".eslintrc.yaml" -o -f ".eslintrc.yml" -o -f ".eslintrc.json" -o -f ".eslintrc" ]; then
  echo -e "${RED}Existing ESLint config file(s) found:${NC}"
  ls -a .eslint* | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} there is loading priority when more than one config file is present: https://eslint.org/docs/user-guide/configuring#configuration-file-formats"
  echo
  read -p  "Write .eslintrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping ESLint config${NC}"
    skip_eslint_setup="true"
  fi
fi
finished=false

# Max Line Length Prompt
while ! $finished; do
  read -p "What max line length do you want to set for ESLint and Prettier? (Recommendation: 80)"
  if [[ $REPLY =~ ^[0-9]{2,3}$ ]]; then
    max_len_val=$REPLY
    finished=true
    echo
  else
    echo -e "${YELLOW}Please choose a max length of two or three digits, e.g. 80 or 100 or 120${NC}"
  fi
done

# Trailing Commas Prompt
echo "What style of trailing commas do you want to enforce with Prettier?"
echo -e "${YELLOW}>>>>> See https://prettier.io/docs/en/options.html#trailing-commas for more details.${NC}"
select trailing_comma_pref in "none" "es5" "all"; do
  case $trailing_comma_pref in
    none ) break;;
    es5 ) break;;
    all ) break;;
  esac
done
echo

# Arrow Function Parentheses
echo "Include parentheses around a sole arrow function parameter?"
select arrow_func_par in "always" "avoid"; do
  case $arrow_func_par in
    always ) break;;
    avoid ) break;;
  esac
done
echo

# Checks for existing prettierrc files
if [ -f ".prettierrc.js" -o -f "prettier.config.js" -o -f ".prettierrc.yaml" -o -f ".prettierrc.yml" -o -f ".prettierrc.json" -o -f ".prettierrc.toml" -o -f ".prettierrc" ]; then
  echo -e "${RED}Existing Prettier config file(s) found${NC}"
  ls -a | grep "prettier*" | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} The configuration file will be resolved starting from the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found. https://prettier.io/docs/en/configuration.html"
  echo
  read -p  "Write .prettierrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping Prettier config${NC}"
    skip_prettier_setup="true"
  fi
  echo
fi

# ----------------------
# Perform Configuration
# ----------------------
echo
echo -e "${GREEN}Configuring your development environment... ${NC}"

echo
echo -e "1/6 ${LCYAN}ESLint & Prettier Installation... ${NC}"
echo
$pkg_cmd -D eslint_d @fsouza/prettierd

echo
echo -e "2/6 ${YELLOW}Conforming to Airbnb's JavaScript Style Guide... ${NC}"
echo
if [ "$typescript_choice" == "Yes" ]; then
  $pkg_cmd -D eslint-config-airbnb eslint-plugin-jsx-a11y eslint-plugin-import eslint-plugin-react @babel/eslint-parser @babel/preset-react @babel/core eslint-plugin-react-hooks eslint-plugin-html @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-config-airbnb-typescript
else
  $pkg_cmd -D eslint-config-airbnb eslint-plugin-jsx-a11y eslint-plugin-import eslint-plugin-react @babel/eslint-parser @babel/preset-react @babel/core eslint-plugin-react-hooks eslint-plugin-html
fi

echo
echo -e "3/6 ${LCYAN}Making ESlint and Prettier play nice with each other... ${NC}"
echo "See https://github.com/prettier/eslint-config-prettier for more details."
echo
$pkg_cmd -D eslint-config-prettier eslint-plugin-prettier

if [ "$typescript_choice" == "Yes" ]; then
  if [ "$skip_eslint_setup" == "true" ]; then
    break
  else
    echo
    echo -e "4/6 ${YELLOW}Building your .eslintrc${config_extension} file...${NC}"
    > ".eslintrc${config_extension}" # truncates existing file (or creates empty)

    echo ${config_opening}'
    "extends": [
      "plugin:@typescript-eslint/recommended",
      "airbnb-typescript",
      "plugin:@typescript-eslint/recommended-requiring-type-checking",
      "plugin:react-hooks/recommended",
      "plugin:jsx-a11y/recommended",
      "plugin:react/recommended",
      "plugin:import/errors",
      "plugin:import/warnings",
      "airbnb",
      "prettier"
    ],
    "plugins": ["@typescript-eslint", "prettier", "jsx-a11y", "react", "html", "react-hooks"],
    "globals": {
      "React": true,
      "JSX": true
    },    
    "env": {
      "browser": true,
      "commonjs": true,
      "es2021": true,
      "jest": true,
      "node": true
    },
    "parser": "@typescript-eslint/parser",
    "parserOptions": {
       "project": "./tsconfig.json",
       "ecmaFeatures": {
           "jsx": true
        },
        "ecmaVersion": 12,
        "sourceType": "module",
        "requireConfigFile": false,      
        "babelOptions": {
          "presets": ["@babel/preset-react"]
        }      
    },
    "rules": {
      "@typescript-eslint/no-misused-promises": [
        "error",
        {
          "checksVoidReturn": false
        }
      ],
      "@typescript-eslint/no-explicit-any": "off",
      "no-redeclare": "off",
      "@typescript-eslint/no-redeclare": [
        "warn",
        {
          "ignoreDeclarationMerge": true
        }
      ],
      "@typescript-eslint/no-floating-promises": "off",
      "no-console": "off",
      "func-names": "off",
      "object-shorthand": "warn",
      "class-methods-use-this": "off",
      "prettier/prettier": "error",
      "no-unused-vars": "warn",
      "spaced-comment": "warn",
      "react/jsx-filename-extension": [
        "error",
        {
          "extensions": [".js", ".jsx", ".ts", ".tsx", ".mdx"]
        }
      ],
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",
      "@typescript-eslint/comma-dangle": ["off"],
      "react/jsx-props-no-spreading": "warn",    
      "react/react-in-jsx-scope": "warn",
      "jsx-a11y/href-no-hash": "off",
      "jsx-a11y/anchor-is-valid": [
        "warn",
        {
          "aspects": ["invalidHref"]
        }
      ],
      "no-shadow": [
        "off",
        {
          "hoist": "all",
          "allow": ["resolve", "reject", "done", "next", "err", "error"]
        }
      ],           
      "max-len": [
        "warn",
        {
          "code": '${max_len_val}',
          "tabWidth": 2,
          "comments": '${max_len_val}',
          "ignoreComments": false,
          "ignoreTrailingComments": true,
          "ignoreUrls": true,
          "ignoreStrings": true,
          "ignoreTemplateLiterals": true,
          "ignoreRegExpLiterals": true
        }
      ]
    }
  }' >> .eslintrc${config_extension}
  fi
else
  if [ "$skip_eslint_setup" == "true" ]; then
    break
  else
    echo
    echo -e "4/6 ${YELLOW}Building your .eslintrc${config_extension} file...${NC}"
    > ".eslintrc${config_extension}" # truncates existing file (or creates empty)

    echo ${config_opening}'
    "extends": [
      "plugin:react-hooks/recommended",
      "plugin:jsx-a11y/recommended",
      "plugin:react/recommended",
      "plugin:import/errors",
      "plugin:import/warnings",
      "airbnb",
      "prettier"
    ],
    "plugins": ["prettier", "jsx-a11y", "react", "html", "react-hooks"],
    "env": {
      "browser": true,
      "commonjs": true,
      "es2021": true,
      "jest": true,
      "node": true
    },
    "parser": "@babel/eslint-parser",
    "parserOptions": {
       "ecmaFeatures": {
           "jsx": true
        },
        "ecmaVersion": 12,
        "sourceType": "module",
        "requireConfigFile": false,      
        "babelOptions": {
          "presets": ["@babel/preset-react"]
        }      
    },
    "rules": {
      "no-console": "off",
      "func-names": "off",
      "object-shorthand": "warn",
      "class-methods-use-this": "off",
      "prettier/prettier": "error",
      "no-unused-vars": "warn",
      "spaced-comment": "warn",
      "react/jsx-filename-extension": [
        "error",
        {
          "extensions": [".js", ".jsx", ".ts", ".tsx", ".mdx"]
        }
      ],
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",
      "@typescript-eslint/comma-dangle": ["off"],
      "react/jsx-props-no-spreading": "warn",    
      "react/react-in-jsx-scope": "warn",
      "jsx-a11y/href-no-hash": "off",
      "jsx-a11y/anchor-is-valid": [
        "warn",
        {
          "aspects": ["invalidHref"]
        }
      ],
      "no-shadow": [
        "off",
        {
          "hoist": "all",
          "allow": ["resolve", "reject", "done", "next", "err", "error"]
        }
      ],     
      "max-len": [
        "warn",
        {
          "code": '${max_len_val}',
          "tabWidth": 2,
          "comments": '${max_len_val}',
          "ignoreComments": false,
          "ignoreTrailingComments": true,
          "ignoreUrls": true,
          "ignoreStrings": true,
          "ignoreTemplateLiterals": true,
          "ignoreRegExpLiterals": true
        }
      ]
    }
  }' >> .eslintrc${config_extension}
  fi
fi




if [ "$skip_prettier_setup" == "true" ]; then
  break
else
  echo -e "5/6 ${YELLOW}Building your .prettierrc${config_extension} file... ${NC}"
  > .prettierrc${config_extension} # truncates existing file (or creates empty)

  echo ${config_opening}'
  "printWidth": '${max_len_val}',
  "singleQuote": true,
  "trailingComma": "'${trailing_comma_pref}'",
  "arrowParens": "'${arrow_func_par}'"
}' >> .prettierrc${config_extension}
fi

if [ "$typescript_choice" == "Yes" && "skip_tsconfig_setup" == "false" ]; then
    echo -e "6/6 ${YELLOW}Building your tsconfig.json file... ${NC}"
  > tsconfig.json # truncates existing file (or creates empty)

  echo {'
  "compilerOptions": {
    "experimentalDecorators": true,
    "baseUrl": ".",
    "outDir": "build/dist",
    "module": "esnext",
    "target": "es2017",
    "lib": ["es6", "dom", "esnext.asynciterable", "es2017"],
    "sourceMap": true,
    "allowJs": true,
    "jsx": "react-jsx",
    "moduleResolution": "node",
    "rootDir": "src",
    "forceConsistentCasingInFileNames": true,
    "noImplicitReturns": true,
    "noImplicitThis": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "suppressImplicitAnyIndexErrors": true,
    "noUnusedLocals": true,
    "skipLibCheck": true,
    "allowSyntheticDefaultImports": true,
    "removeComments": true
  },
  "exclude": [
    "node_modules",
    "build",
    "scripts",
    "acceptance-tests",
    "webpack",
    "jest",
    "src/setupTests.ts"
  ]
}' >> tsconfig.json
else
  break
fi

echo
echo -e "${GREEN}Finished setting up!${NC}"
echo
