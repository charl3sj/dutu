export default function selectNearestRadio(el) {
    let getNearestRadioButton = el => el.closest('.input-group').firstElementChild
    let nearestRadioButton = getNearestRadioButton(el)
    function clearOtherInputs() {
        let optionInputs = document.querySelectorAll('.radio-linked-input')
        Array.from(optionInputs).map(inputElem => {
            if (getNearestRadioButton(inputElem) !== nearestRadioButton) inputElem.value = ''
        })
    }
    clearOtherInputs()
    nearestRadioButton.checked = true
}