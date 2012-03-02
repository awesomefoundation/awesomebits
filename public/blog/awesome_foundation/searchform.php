<form role="search" method="get" id="searchform" action="<?php echo home_url( '/' ); ?>">
	<div><label class="screen-reader-text" for="s">search for</label>
		<input type="text" value="<?php echo $_GET['s'] ?>" name="s" id="s" />
	</div>
</form>