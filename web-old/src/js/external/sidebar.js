'use strict';

import { sidebar } from 'bootstrap-layout';
import { sidebarId, layoutContainerId, layoutContainerSidebarClass, entriesId } from '../config';
import $ from 'jquery';

export const sbInit = () => {
  sidebar.init(`#${sidebarId}`);
};

export const sbToggle = () => {
  if($(`#${layoutContainerId}`).hasClass(layoutContainerSidebarClass)) {
    $(`#${layoutContainerId}`).removeClass(layoutContainerSidebarClass);
  } else {
    $(`#${layoutContainerId}`).addClass(layoutContainerSidebarClass);
  }
  sidebar.toggle(`#${sidebarId}`);
};

export const sbHide = () => {
  $(`#${layoutContainerId}`).removeClass(layoutContainerSidebarClass);
  sidebar.hide(`#${sidebarId}`);
};
export const sbShow = () => {
  if(!$(`#${layoutContainerId}`).hasClass(layoutContainerSidebarClass)) {
    $(`#${layoutContainerId}`).addClass(layoutContainerSidebarClass);
  }
  sidebar.show(`#${sidebarId}`);
};

