import { getNotebooks, createNotebook } from '../actions/notebook_actions';
import { getTags, createTag } from '../actions/tag_actions';
import { getNotes } from '../actions/note_actions';
import {
  closeNotebooksModal,
  closeTagsModal,
  closeShortcutsModal
} from '../actions/ui_actions';
const queryString = require('query-string');

export const sidebarIndexSelector = (state, ownProps) => {
  let entities;
  let fetchAction;
  let createAction;
  let closeModal;
  let modalIsOpen;
  let entityCount;
  const getOptions = {};
  switch (ownProps.type) {
    case 'notebooks':
      fetchAction = getNotebooks;
      if (state) {
        entities = Object.values(state.notebooks).sort((a,b) => {
          const aDate = new Date(a.updated_at);
          const bDate = new Date(b.updated_at);
          return bDate - aDate;
        });
        modalIsOpen = state.ui.notebooksModalIsOpen;
        entityCount = state.ui.notebookCount;
      }
      createAction = createNotebook;
      closeModal = closeNotebooksModal;
      break;
    case 'tags':
      fetchAction = getTags;
      if (state) {
        entities = Object.values(state.tags);
        modalIsOpen = state.ui.tagsModalIsOpen;
        entityCount = state.ui.tagCount;
      }
      createAction = createTag;
      closeModal = closeTagsModal;
      break;
    case 'shortcuts':
      fetchAction = getNotes;
      if (state) {
        entities = Object.values(state.notes);
        modalIsOpen = state.ui.shortcutsModalIsOpen;
        entityCount = state.ui.noteCount;
      }
      closeModal = closeShortcutsModal;
      getOptions.shortcuts = true;
      break;
    default:
      break;
  }
  // if (ownProps.location.search) {
  //   const parsed = queryString.parse(ownProps.location.search);
  //   getOptions.searchTerm = parsed.search;
  // } 
  let searchEntity;
  if (state) {
    getOptions.searchTerm = state.search.searchTerm;
    searchEntity = state.search.searchEntity;
  }
  return {
    entities,
    fetchAction,
    getOptions,
    searchEntity,
    createAction,
    closeModal,
    modalIsOpen,
    entityCount
  };
};
