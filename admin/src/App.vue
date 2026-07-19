<template>
  <router-view />
</template>
<script setup lang="ts"></script>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
:root {
  --el-font-size-extra-large: 28px;
  --el-font-size-large: 24px;
  --el-font-size-medium: 21px;
  --el-font-size-base: 20px;
  --el-font-size-small: 18px;
  --el-font-size-extra-small: 17px;
}
html {
  font-size: 20px;
}
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #f0f2f5;
  color: #303133;
  font-size: 20px;
}
#app {
  min-height: 100vh;
  font-size: 20px;
}
.el-card,
.el-menu,
.el-form,
.el-table,
.el-descriptions,
.el-tabs,
.el-dialog,
.el-drawer {
  font-size: 20px;
}
.el-button,
.el-input__inner,
.el-textarea__inner,
.el-select__placeholder,
.el-select__selected-item,
.el-select-dropdown__item,
.el-form-item__label,
.el-form-item__content,
.el-radio,
.el-checkbox,
.el-pagination,
.el-message-box,
.el-dialog,
.el-dropdown-menu__item,
.el-date-editor,
.el-picker-panel {
  font-size: 20px !important;
}
.el-table {
  font-size: 19px !important;
}
.el-table th.el-table__cell {
  font-size: 19px !important;
}
.el-table .cell {
  line-height: 1.7;
}
.el-input__wrapper,
.el-select__wrapper {
  min-height: 46px;
}
.el-button {
  min-height: 46px;
  padding-left: 20px;
  padding-right: 20px;
}
.el-tag {
  font-size: 17px !important;
  padding: 0 12px;
}
.el-form-item {
  margin-bottom: 24px;
}
.el-dialog__title,
.el-message-box__title {
  font-size: 24px !important;
}
.el-card__header {
  font-size: 22px;
}
</style>
