let uploaders = [];

function addUploadedFile(element, file, response) {
  const strategy = element.dataset.uploaderStrategy;

  const original = document.getElementById('js-uploader__file-template');
  const clone = original.content.cloneNode(true);

  const img = clone.querySelector('img');
  const name = clone.querySelector('span')
  const imageData = clone.querySelector('.js-image-data');

  const randomId = Math.floor(Math.random() * 1000000000);

  clone.querySelectorAll('input').forEach((item) => {
    item.name = item.name.replace(/\[\d+\]/, `[${randomId}]`);
  });

  img.src = response.uploadURL;
  name.innerHTML = file.data.name;

  let uploadId = response.uploadURL;

  if (strategy == "s3") {
    // extract key without prefix
    uploadId = uploadId.match(/\/uploads\/([^\?]+)/)[1];
  }

  imageData.value = JSON.stringify({
    id: uploadId,
    storage: 'cache',
    metadata: {
      size:      file.size,
      filename:  file.name,
      mime_type: file.type,
    }
  });

  const target = element.querySelector('.js-uploader__uploaded-files');

  if (target) {
    target.appendChild(clone);
    reorderPhotos(target);
  }

  updateFileRestrictions(element);
}

function addUploadError(container, message) {
  clearUploadError(container);

  const node = document.createElement('div');
  node.classList.add('error');
  const p = document.createTextNode(message);
  node.appendChild(p);
  const target = container.querySelector('.js-uploader__dropzone').after(node);
}

function clearUploadError(container) {
  const child = container.querySelector('.error');

  if (child) {
    child.parentNode.removeChild(child);
  }
}

function updateFileRestrictions(element) {
  const uploaderName = element.dataset.uploaderName;
  const maxFiles = parseInt(element.dataset.maxFiles);
  const remainingFiles = maxFiles - element.querySelectorAll('.js-uploader__element:not(.hidden)').length;

  if (maxFiles) {
    uploaders[uploaderName].setOptions({
      restrictions: {
        maxNumberOfFiles: remainingFiles,
      }
    })

    const button = element.querySelector('.js-uploader__dropzone').querySelector('button');

    if (remainingFiles < 1) {
      button.disabled = true;
    } else {
      button.disabled = false;
    }
  }
}

function registerRemoveClicks(container) {
  $(container).find('.remove-image').on('click', function(event) {
    event.stopPropagation();
    event.preventDefault();

    $(this.parentNode).find('.js-uploader__destroy-field').each(function() {
      this.value = "1";
    });

    $(this.parentNode).addClass('hidden');

    // TODO Call uppy.removeFile to remove the file from the uploader
    // so the user can upload it again if they removed it by accident

    updateFileRestrictions(container);
  })
}

function reorderPhotos(container) {
  container.querySelectorAll('.js-uploader__element').forEach((element, index) => {
    const field = element.querySelector('.js-uploader__sort-field');
    field.value = index;
  })
}

window.onload = function() {
  document.querySelectorAll('.js-uploader').forEach((container) => {
    const observer = new MutationObserver((mutations, observer) => {
      mutations.forEach((mutation) => {
        registerRemoveClicks(mutation.target.closest('.js-uploader'));
      })
    });

    observer.observe(container, { subtree: true, childList: true });

    $(container).find('.js-uploader__uploaded-files').sortable({
      update: function(event, ui) {
        reorderPhotos(event.target);
      }
    });

    const uploaderName = container.dataset.uploaderName;
    const fileTypes = container.dataset.fileTypes;
    const strategy = container.dataset.uploaderStrategy;

    let uppy = new Uppy.Uppy({ id: uploaderName, debug: true, autoProceed: true })
    uppy.use(Uppy.DragDrop, { target: '.js-uploader__dropzone' })
    uppy.use(Uppy.ProgressBar, { target: '.js-uploader__progress-bar', hideAfterFinish: true })

    if (strategy == "s3") {
      uppy.use(Uppy.AwsS3Multipart, {
        limit: 5,
        timeout: 60 * 1000,
        companionUrl: '/',
      })
    } else {
      uppy.use(Uppy.Tus, {
        endpoint: '/uploads',
        chunksize: 5*1024*1024,
      })
    }

    if (fileTypes) {
      uppy.setOptions({ restrictions: { allowedFileTypes: fileTypes.split(",") } })
    }

    uppy.on('upload-success', (file, response) => {
      addUploadedFile(container, file, response)
    })

    uppy.on('upload-error', (file, error, response) => {
      addUploadError(container, error.message)
    })

    uppy.on('upload', (files) => {
      clearUploadError(container)
    })

    uppy.on('restriction-failed', (file, error) => {
      addUploadError(container, error.message)
    })

    uploaders[uploaderName] = uppy;

    registerRemoveClicks(container);
    updateFileRestrictions(container);
  })
}
