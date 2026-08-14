# Example_Flow_Rich_Text_Text_Area_Flow

## Description



## Label

Example Flow Component Hyphen8

## API Version

62.0

## Flow Type

Flow

## Status

Draft

## Template

false

## Interview Label

Example Flow Rich Text / Text Area Flow {!$Flow.CurrentDateTime}

## Variables

| Name | DataType | ObjectOrClass | Collection | Input | Output | Default |
| --- | --- | --- | --- | --- | --- | --- |
| exampleRichTextCharacterCount | String |  | false | false | false |  |
| exampleTextAreaCharacterCount | String |  | false | false | false |  |
| exampleTextAreaWordCount | String |  | false | false | false |  |
| richTextWordCount | String |  | false | false | false |  |
| timeValue | String |  | false | false | false |  |

## Flow Elements

| Name | Label | Type | Detail |
| --- | --- | --- | --- |
| Example_File_Upload_Component | Example File Upload Component | Screen | 2 field(s), 2 component instance(s) |
| Example_Text_Area_Output_Screen | Example Text Area Output Screen | Screen | 6 field(s), 6 component instance(s) |
| Text_Area_Example_Input_Screen | Example Text Area Input Screen | Screen | 7 field(s), 7 component instance(s) |
| Assign_Page_1 | Assign Page 1 | Assignment | 1 item(s) |
| Assign_Page_2 | Assign Page 2 | Assignment | 1 item(s) |
| Assign_Page_3 | Assign Page 3 | Assignment | 1 item(s) |

## Screen Components

| Screen | Field | Component | Inputs |
| --- | --- | --- | --- |
| Example File Upload Component | Page3Nav | c:FlowStageNavigation | currentStage=$Flow.CurrentStage, stages=$Flow.ActiveStages |
| Example File Upload Component | BasicFileUploadConfiguration | c:h8FlowFileUploads | acceptedFormats=.pdf, allowMultipleFiles=true, disableFileDelete=false, fileUploadLabel=Upload Files, helpText=Some sample help text, required=true, requiredValidationMessage=You have to upload at least 1 file, showUploadButton=true, uploadedlabel=Files you have already uploaded |
| Example Text Area Output Screen | Page2Nav | c:FlowStageNavigation | currentStage=$Flow.CurrentStage, stages=$Flow.ActiveStages |
| Example Text Area Output Screen | TextAreaOutputCharacterCount | c:customTextAreaComponent | disabled=true, label=Character Count Text Area Output, readOnly=true, required=false, value=exampleTextAreaCharacterCount, variant=label-stacked, textAreaHeight=250px, displayCharacterCount=false, displayWordCount=false |
| Example Text Area Output Screen | TextAreaExampleWordCountOutput | c:customTextAreaComponent | disabled=true, label=Word Count output Example, readOnly=true, required=false, value=exampleTextAreaWordCount, variant=label-stacked, textAreaHeight=250px, displayCharacterCount=false, displayWordCount=false |
| Example Text Area Output Screen | RichTextOutputCharacterCount | c:customRichTextComponent | disabled=true, label=Rich Text Output Character Count, labelVisible=true, value=exampleRichTextCharacterCount, textAreaHeight=250px, readOnly=true, required=false, displayCharacterCount=false, displayWordCount=false |
| Example Text Area Output Screen | RichTextWordCountOutput | c:customRichTextComponent | disabled=true, label=Rich Text WordCount Output, labelVisible=true, readOnly=true, required=false, value=richTextWordCount, textAreaHeight=250px, displayCharacterCount=false, displayWordCount=false |
| Example Text Area Output Screen | exampleTimeOutput | c:customTimeComponent | disabled=true, required=false, value=timeValue, label=Example Time Output |
| Example Text Area Input Screen | Page1Nav | c:FlowStageNavigation | currentStage=$Flow.CurrentStage, stages=$Flow.ActiveStages |
| Example Text Area Input Screen | customPrintButtonDemo | c:customPrintButton | buttonAssistiveText=Print Page, buttonFloat=slds-float_right, buttonLabel=Print |
| Example Text Area Input Screen | CustomTextAreaExampleInput | c:customTextAreaComponent | disabled=false, displayCharacterCount=true, displayWordCount=false, fieldLevelHelp=You need to provide some help text on this field to support input in a popover, label=Character Count Text Area Example, maxCharacterCount=255, maxCharacterCountMessage=Please review what you have submitted, you are limited to 255 characters., readOnly=false, placeholder=Enter placeholder in here for when the value is not present, required=true, requireFieldMessage=This is a required field, value=exampleTextAreaCharacterCount, variant=label-stacked, textAreaHeight=200px, minCharacterCount=50, minCharacterCountMessage=You have to provide more than 50 characters here |
| Example Text Area Input Screen | workcounttextareainput | c:customTextAreaComponent | disabled=false, displayCharacterCount=false, displayWordCount=true, fieldLevelHelp=This is a work count text area input, label=Word count example text area, maxWordCount=50, maxWordCountMessage=You have exceeded the maximum number of words allowed., placeholder=Enter some text in here, readOnly=false, required=false, requireFieldMessage=This field is required you can only continue once you have completed this field., value=exampleTextAreaWordCount, variant=label-stacked, textAreaHeight=200px |
| Example Text Area Input Screen | RichTextCharacterCount | c:customRichTextComponent | disabled=false, displayCharacterCount=true, displayWordCount=false, fieldLevelHelp=This is a rich text character count example, label=Rich Text Character Count Example, labelVisible=true, maxCharacterCount=1000, maxCharacterCountMessage=You have entered to many characters for this field, please review and adjust your text before continuing., placeholder=Enter text in here, readOnly=false, required=true, requireFieldMessage=This is a required field please complete before continuing, value=exampleRichTextCharacterCount, formats=font,size,bold,italic,underline,strike,list, textAreaHeight=225px |
| Example Text Area Input Screen | RichTextWordCountInput | c:customRichTextComponent | disabled=false, displayCharacterCount=false, displayWordCount=true, fieldLevelHelp=Word Count input example, label=Rich Text Word Count Input Example, labelVisible=true, maxWordCount=100, maxWordCountMessage=Please reduce the number of words, placeholder=Enter text in here, readOnly=false, required=true, requireFieldMessage=You need to provide a value in this field, value=richTextWordCount, textAreaHeight=225px |
| Example Text Area Input Screen | exampleTimeInput | c:customTimeComponent | disabled=false, label=Example Time Input field, required=true, value=timeValue, requiredMessage=A value needs to be selected in this field to progress, maxValue=17:30:00.000Z, minValue=09:00:00.000Z |

## Source File

- `force-app/main/default/flows/Example_Flow_Rich_Text_Text_Area_Flow.flow-meta.xml`
