var CommentStore = {
  items: [],
  subscribers: [],

  subscribe: function(parent, callback) {
    this.subscribers.push({ parent: parent, callback: callback });
  },

  unsubscribe: function(parent, callback) {
    this.subscribers.filter(subscriber => (subscriber.parent == parent && subscriber.callback == callback));
  },

  setComments: function(comments) {
    this.items = comments;

    this.subscribers.map((subscriber) => {
      subscriber.callback(subscriber.parent);
    });
  },

  getComments: function(projectId) {
    return this.items.filter(comment => comment.project_id == projectId);
  }
};
