<template>
  <router-view />
</template>

<script setup lang="ts">
</script>

<style>
:root {
  --el-font-size-extra-large: 28px;
  --el-font-size-large: 24px;
  --el-font-size-medium: 21px;
  --el-font-size-base: 20px;
  --el-font-size-small: 18px;
  --el-font-size-extra-small: 17px;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  font-size: 20px;
  background: #f5f7fa;
}
#app { min-height: 100vh; font-size: 20px; }
.el-menu-item,
.el-button,
.el-input__inner,
.el-textarea__inner,
.el-form-item__label,
.el-table,
.el-dialog,
.el-card,
.el-dropdown-menu__item {
  font-size: 20px;
}
.el-button--small,
.el-tag,
.el-select-dropdown__item,
.el-pagination,
.el-form-item__error {
  font-size: 18px;
}
.el-menu--horizontal > .el-menu-item {
  font-size: 20px;
}
.el-button {
  min-height: 42px;
  padding: 10px 18px;
}
.el-button--small {
  min-height: 36px;
  padding: 8px 14px;
}
.el-input__wrapper,
.el-textarea__inner {
  font-size: 20px;
}
.el-form-item__label {
  line-height: 42px;
}
.el-table .cell {
  line-height: 1.6;
}
.el-dialog__title {
  font-size: 24px;
}
</style>
