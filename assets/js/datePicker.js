import flatpickr from "flatpickr"

const minDate = val => {
    const dt = new Date(val)
    const today = new Date()
    return dt < today ? val : "today"
}

const datePicker = {
    mounted() {
        this.pickr = flatpickr(this.el, {
            minDate: minDate(this.el.value),
            altInput: true,
            altFormat: "M d",
            dateFormat: this.el.dataset.pickrDateFormat || "Y-m-d"
        })
    },
    updated() {
        const altFormat = this.el.dataset.pickrAltFormat
        const wasFormat = this.pickr.config.altFormat
        if (altFormat !== wasFormat) {
            this.pickr.destroy()
            this.pickr = flatpickr(this.el, {
                minDate: minDate(this.el.value),
                altInput: true,
                altFormat: "M d",
                dateFormat: this.el.dataset.pickrDateFormat || "Y-m-d"
            })
        }
    },
    destroyed() {
        this.pickr.destroy()
    }
}

export default datePicker