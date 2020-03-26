var CommentStore = {
  items: [],
  subscribers: [],

  subscribe: function(callback) {
    this.subscribers.push(callback);
  },

  unsubscribe: function(callback) {
    this.subscribers = this.subscribers.filter(subscriber => (subscriber !== callback));
  },

  notifySubscribers: function() {
    this.subscribers.map((subscriber) => {
      subscriber();
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
