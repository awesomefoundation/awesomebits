var CommentList = createReactClass({
  propTypes: {
    projectId: PropTypes.number,
    initialComments: PropTypes.array
  },

  getInitialState: function() {
    CommentStore.subscribe(this, this.updateComments);

    return {
      comments: this.props.initialComments
    }
  },

  componentWillUnmount: function() {
    CommentStore.unsubscribe(this, this.updateComments);
  },

  updateComments: function(that) {
    that.setState({ comments: CommentStore.getComments(that.props.projectId) });
  },
  
  render: function() {
    comments = this.state.comments || [];

    this.items = comments.map((comment) =>
      <div className="project__comment-wrapper" key={comment.id}>
        <figure className="user__image">
          <img src={comment.user_gravatar_url} />
        </figure>
        <div className="project__comment">
          <header>
            {comment.user_name}
            <time dateTime={comment.createdAt}> - {comment.created_at_human}</time>
            <i className={"icon icon-"+comment.visibility_class+" comment__visible-icon"} title={comment.viewable_by}></i>
          </header>
          <div dangerouslySetInnerHTML={{__html: comment.body}}></div>
        </div>
      </div>
    );

    return (
      <React.Fragment>{this.items}</React.Fragment>
    );
  }
});
