open CoursesCurriculum__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__SubmissionItem")
let ts = I18n.ts

let kindIconClasses = result =>
  switch (result: ChecklistItem.result) {
  | ShortText(_text) => "if i-short-text-regular md:text-base text-gray-800 if-fw"
  | LongText(_markdown) => "if i-long-text-regular md:text-base text-gray-800 if-fw"
  | Link(_link) => "if i-link-regular md:text-base text-gray-800 if-fw"
  | MultiChoice(
      _choices,
      _selected,
    ) => "if i-check-circle-alt-regular md:text-base text-gray-800 if-fw"
  | Files(_attachments) => "if i-file-regular md:text-base text-gray-800 if-fw"
  | AudioRecord(_attachments) => "if i-microphone-outline-regular md:text-base text-gray-800 if-fw"
  }

let computeId = (index, checklistItem) =>
  (index |> string_of_int) ++ ("-" ++ ChecklistItem.kindAsString(checklistItem))

let notBlank = string => string |> String.trim != ""

let placeholder = (id, checklistItem) => {
  let title = checklistItem |> ChecklistItem.title
  let optional = checklistItem |> ChecklistItem.optional
  <div className="flex items-start">
    <PfIcon className={kindIconClasses(checklistItem->ChecklistItem.result)} />
    <label htmlFor=id className="font-semibold text-sm ltr:pl-2 rtl:pr-2 tracking-wide">
      <MarkdownBlock
        profile=Markdown.Permissive
        markdown={title ++ (optional ? " (" ++ ts("optional") ++ ")" : "")}
      />
    </label>
  </div>
}

let showError = (message, active) =>
  if active {
    <div
      className="mt-1 px-1 py-px rounded text-xs font-semibold text-red-600 bg-red-100 inline-flex items-center">
      <span className="ltr:mr-2 rtl:ml-2"> <i className="fas fa-exclamation-triangle" /> </span>
      <span> {message |> str} </span>
    </div>
  } else {
    React.null
  }

let showLink = (value, id, updateResultCB) =>
  <div>
    <input
      id
      type_="text"
      value
      onChange={e => updateResultCB(ChecklistItem.Link(ReactEvent.Form.target(e)["value"]))}
      placeholder={tr("link_placeholder")}
      className="cursor-pointer truncate h-10 border border-gray-300 focus:outline-none focus:border-primary-400 focus:shadow-inner px-4 items-center font-semibold rounded text-sm ltr:mr-2 rtl:ml-2 block w-full"
    />
    {showError(tr("link_error"), UrlUtils.isInvalid(true, value))}
  </div>

let showShortText = (value, id, updateResultCB) =>
  <div>
    <input
      id
      type_="text"
      value
      maxLength=250
      onChange={e => updateResultCB(ChecklistItem.ShortText(ReactEvent.Form.target(e)["value"]))}
      placeholder={tr("short_text_placeholder")}
      className="cursor-pointer truncate h-10 border border-gray-300 focus:outline-none focus:border-primary-400 focus:shadow-inner px-4 items-center font-semibold rounded text-sm ltr:mr-2 rtl:ml-2 block w-full"
    />
    {showError(tr("short_text_error"), !ChecklistItem.validShortText(value) && notBlank(value))}
  </div>

let longTextWarning = value => {
  let currentLength = value |> String.length
  let showWarning = notBlank(value) && currentLength > 4500

  let colors = currentLength < 4900 ? "text-orange-700 bg-orange-100" : "text-red-600 bg-red-100"

  showWarning
    ? <div className="flex justify-between items-center mt-1">
        <div
          className={"hidden md:inline px-2 py-px rounded text-xs font-semibold inline-flex items-center " ++
          colors}>
          <span className="ltr:mr-2 rtl:ml-2"> <i className="fas fa-exclamation-triangle" /> </span>
          <span> {tr("warning_length_limit") |> str} </span>
        </div>
        <div
          className={"shrink-1 text-tiny font-semibold px-1 py-px border border-transparent rounded " ++
          colors}>
          {currentLength |> string_of_int |> str} {" / 5000" |> str}
        </div>
      </div>
    : React.null
}

let updateLongText = (updateResultCB, value) => updateResultCB(ChecklistItem.LongText(value))

let showLongText = (value, id, updateResultCB) =>
  <div>
    <MarkdownEditor
      textareaId=id
      onChange={updateLongText(updateResultCB)}
      value
      profile=Markdown.Permissive
      maxLength=5000
    />
    {longTextWarning(value)}
  </div>

let checkboxOnChange = (choices, itemIndex, updateResultCB, event) =>
  ReactEvent.Form.target(event)["checked"]
    ? updateResultCB(ChecklistItem.MultiChoice(choices, Some(itemIndex)))
    : updateResultCB(ChecklistItem.MultiChoice(choices, None))

let showMultiChoice = (choices, choice, id, updateResultCB) =>
  Js.Array2.mapi(choices, (label, index) => {
    let checked = Belt.Option.mapWithDefault(choice, false, i => i == index)

    <Radio
      key={index |> string_of_int}
      id={id ++ (index |> string_of_int)}
      label
      onChange={checkboxOnChange(choices, index, updateResultCB)}
      checked
    />
  })->React.array

let attachFile = (updateResultCB, attachingCB, files, id, filename) => {
  attachingCB(false)
  updateResultCB(ChecklistItem.Files(files |> Array.append([ChecklistItem.makeFile(id, filename)])))
}
let attachRecordingFile = (updateResultCB, attachingCB, id, filename) => {
  attachingCB(false)
  updateResultCB(ChecklistItem.AudioRecord({id: id, name: filename}))
}

let removeFile = (updateResultCB, files, id) =>
  updateResultCB(
    ChecklistItem.Files(files |> Js.Array.filter(a => a |> ChecklistItem.fileId != id)),
  )

let showFiles = (files, preview, id, attachingCB, updateResultCB, index) =>
  <div>
    <div className="flex flex-wrap" id>
      {files
      |> Array.map(file =>
        <div
          key={"file-" ++ (file |> ChecklistItem.fileId)}
          ariaLabel={"file-" ++ (file |> ChecklistItem.filename)}
          target="_blank"
          className="w-1/3 ltr:pr-2 rtl:pl-2 pb-2">
          <div
            className="flex justify-between border overflow-hidden rounded border-red-300 bg-white text-red-600 hover:text-red-600">
            <div className="flex">
              <span className="flex w-10 justify-center items-center p-2 bg-red-600 text-white">
                <i className="far fa-file" />
              </span>
              <span
                className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-38 ltr:pl-3 rtl:pr-3 ltr:pr-2 rtl:pl-2 py-2 leading-loose">
                {file |> ChecklistItem.filename |> str}
              </span>
            </div>
            <button
              title={tr("remove") ++ (file |> ChecklistItem.filename)}
              className="flex w-8 justify-center items-center p-2 cursor-pointer bg-gray-50 border-l text-gray-600 hover:bg-gray-50 hover:text-gray-900"
              onClick={_ => removeFile(updateResultCB, files, file |> ChecklistItem.fileId)}>
              <PfIcon className="if i-times-regular text-sm" />
            </button>
          </div>
        </div>
      )
      |> React.array}
    </div>
    {files |> Array.length < 3
      ? <CoursesCurriculum__FileForm
          attachingCB attachFileCB={attachFile(updateResultCB, attachingCB, files)} preview index
        />
      : React.null}
  </div>

let showAudioRecorder = (attachingCB, updateResultCB, preview) => {
  <CoursesCurriculum__AudioRecorder
    attachingCB attachFileCB={attachRecordingFile(updateResultCB, attachingCB)} preview
  />
}

@react.component
let make = (~index, ~checklistItem, ~updateResultCB, ~attachingCB, ~preview) => {
  let id = computeId(index, checklistItem)
  <div className="mt-4" ariaLabel=id>
    {placeholder(id, checklistItem)}
    <div className="ltr:md:pl-7 rtl:md:pr-7 pt-2 pr-0 pb-4">
      {switch checklistItem |> ChecklistItem.result {
      | Files(files) => showFiles(files, preview, id, attachingCB, updateResultCB, index)
      | Link(link) => showLink(link, id, updateResultCB)
      | ShortText(shortText) => showShortText(shortText, id, updateResultCB)
      | LongText(longText) => showLongText(longText, id, updateResultCB)
      | MultiChoice(choices, selected) => showMultiChoice(choices, selected, id, updateResultCB)
      | AudioRecord(_) => showAudioRecorder(attachingCB, updateResultCB, preview)
      }}
    </div>
  </div>
}
