import stylistic from "@stylistic/eslint-plugin";
import tseslint from "typescript-eslint";

/** Layout rules formerly expressed in TSLint; enforced via ESLint + @stylistic. */
export default tseslint.config(
  {
    ignores: [
      "**/archive/**",
      "**/coverage/**",
      "**/dist/**",
      "**/out/**",
      "**/out-test/**",
      "**/out-test-integration/**",
      "**/.vscode-test/**",
      "**/node_modules/**",
    ],
  },
  {
    files: ["packages/**/*.ts"],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module",
      },
    },
    plugins: {
      "@stylistic": stylistic,
    },
    rules: {
      "@stylistic/function-call-argument-newline": ["error", "never"],
      "@stylistic/function-paren-newline": ["error", "never"],
    },
  }
);
