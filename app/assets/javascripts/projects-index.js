class ProjectNavigator {
    constructor() {
        this.projects = document.querySelectorAll(".project");
    }

    nextProject() {
        const arr = Array.from(this.projects);

        if (arr.length == 0) {
            return;
        }

        let el = arr.find(function(p, index) {
            let rect = p.getBoundingClientRect();

            if (rect.top > 10) {
                return true;
            }
        });

        if (el === undefined) {
            // End of the list, just scroll to the bottom
            arr[arr.length - 1].parentNode.scrollIntoView({block: "end", behavior: "smooth"});
        } else {
            // scroll to the next item on the page
            el.scrollIntoView({behavior: "smooth"});
        }
    }

    previousProject() {
        const arr = Array.from(this.projects).reverse();

        if (arr.length == 0) {
            return;
        }

        let el = arr.find(function(p, index) {
            let rect = p.getBoundingClientRect();

            if (rect.top < -10) {
                return true;
            }
        });

        if (el === undefined) {
            // End of the list, just scroll to the bottom
            arr[arr.length - 1].parentNode.scrollIntoView({block: "start", behavior: "smooth"});
        } else {
            // scroll to the next item on the page
            el.scrollIntoView({behavior: "smooth"});
        }
    }
}
