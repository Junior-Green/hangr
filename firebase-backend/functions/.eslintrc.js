module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  settings: {
    "import/resolver": {
      node: {
        paths: ["src"],
        extensions: [".js", ".jsx", ".ts", ".tsx"],
        moduleDirectory: ["node_modules", "src/"],
      },
    },
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
    tsconfigRootDir: __dirname,
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
  ],
  plugins: [
    "@typescript-eslint",
    "import",
    "promise",
  ],
  rules: {
    "quotes": ["error", "double"],
    "require-jsdoc": "off",
    "max-len": ["error", {"ignoreStrings": true, "ignoreTemplateLiterals": true}],
    "no-invalid-this": "off",
    "indent": 0,
  },
};
