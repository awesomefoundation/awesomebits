var CommentStore = {
  items: [],
  subscribers: [],

  subscribe: function(parent, callback) {
    this.subscribers.push({ parent: parent, callback: callback });
  },

  unsubscribe: function(parent, callback) {
    this.subscribers = this.subscribers.filter(subscriber => (subscriber.parent == parent && subscriber.callback == callback));
  },

  notifySubscribers: function() {
    this.subscribers.map((subscriber) => {
      subscriber.callback(subscriber.parent);
    });
  },

  getComments: function(projectId) {
    return this.items.filter(comment => comment.project_id == projectId);
  },

  setComments: function(comments, projectId) {
    if (projectId !== null) {
      this.items = this.items.filter(item => item.project_id != projectId);
      this.items = this.items.concat(comments);

    } else {
      this.items = comments;
    }

    this.notifySubscribers();
  },

  removeComment: function(commentId) {
    this.items = this.items.filter(item => item.id != commentId);

    this.notifySubscribers();
  }
};
