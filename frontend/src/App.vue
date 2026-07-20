<template>
  <router-view />
</template>

<script setup lang="ts">
</script>

<style>
:root {
  --el-font-size-extra-large: 18px;
  --el-font-size-large: 16px;
  --el-font-size-medium: 15px;
  --el-font-size-base: 14px;
  --el-font-size-small: 13px;
  --el-font-size-extra-small: 12px;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  background: #f5f7fa;
}
#app { min-height: 100vh; font-size: 14px; }
.el-menu-item,
.el-button,
.el-input__inner,
.el-textarea__inner,
.el-form-item__label,
.el-table,
.el-dialog,
.el-card,
.el-dropdown-menu__item {
  font-size: 14px;
}
.el-button--small,
.el-tag,
.el-select-dropdown__item,
.el-pagination,
.el-form-item__error {
  font-size: 12px;
}
.el-menu--horizontal > .el-menu-item {
  font-size: 14px;
}
.el-button {
  min-height: 32px;
  padding: 6px 12px;
}
.el-button--small {
  min-height: 28px;
  padding: 4px 10px;
}
.el-input__wrapper,
.el-textarea__inner {
  font-size: 14px;
}
.el-form-item__label {
  line-height: 32px;
}
.el-table .cell {
  line-height: 1.5;
}
.el-dialog__title {
  font-size: 16px;
}
</style>
