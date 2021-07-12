# Hyphen8 Custom Flow LWC Components

A collection of LWC Flow components that we have build to expend the capabilities within flow and to support our end user requirements.
This package comes with an example inactive flow associated with it, this flow is not to be used or activated as it will be updated in future releases as more components are added to this library.

## Installation

- Production (https://login.salesforce.com/packaging/installPackage.apexp?p0=04t67000000SalGAAS)
- Sandbox (https://test.salesforce.com/packaging/installPackage.apexp?p0=04t67000000SalGAAS)

## Custom Labels
- WordCountText - Used for outputting text at the beginning of the word counter
- CharacterCountText - Used for outputting text at the beginning of the character counter


## customRichTextComponent
- Uses the native lightning-input-rich-text and so some limits with this still apply around styling
- Extended to provide the ability to display a Word count and word count error message
- Extended to provide the ability to display a Character count and a character count error message

### input parameters
- Value - The HTML content in the rich text editorgi
- Label - The label of the rich text editor
- Help Text - The help text that appears in a popover
- Required - If present, the textarea field must be filled out before the form can be submitted
- Read Only - If present, the textarea field is read-only and cannot be edited
- Disabled - If present, the textarea field is disabled and users cannot interact with it
- Label Visible - If present, the label on the rich text editor is visible
- Placeholder - Text that is displayed when the field is empty, to prompt the user for a valid entry
- Max Character Count - Maximum number of characters allowed
- Max Character Count Message - Maximum number of characters allowed error message
- Max Word Count - Maximum number of words allowed
- Max Word Count Message - Maximum number of words allowed error message
- Formats - A list of allowed formats. By default, the list is computed based on enabled categories. The 'table' format is always enabled to support copying and pasting of tables if formats are not provided
- Display Character Count - Confirm that you want to apply and display the character count on page
- Display Character Count Location - Confirm if you want to display the count on the left or right
- Display Word Count - Confirm that you want to apply and display the word count on page
- Display Word Count Location - Confirm if you want to display the count on the left or right

### output parameters
- Value - The HTML content in the rich text editor

## customTextAreaComponent
- Uses the native lightning-textarea and so some limits with this still apply around styling
- Extended to provide the ability to display a Word count and word count error message
- Extended to provide the ability to display a Character count and a character count error message

### input parameters
- Value - The content in the text area
- Label - The label of the rich text editor
- Help Text - The help text that appears in a popover
- Required - If present, the textarea field must be filled out before the form can be submitted
- Read Only - If present, the textarea field is read-only and cannot be edited
- Disabled - If present, the textarea field is disabled and users cannot interact with it
- Variant - The variant changes the appearance of the textarea. Accepted variants include standard, label-hidden, label-inline, and label-stacked. This value defaults to standard. Use label-hidden to hide the label but make it available to assistive technology. Use label-inline to horizontally align the label and textarea. Use label-stacked to place the label above the textarea
- Placeholder - Text that is displayed when the field is empty, to prompt the user for a valid entry
- Max Character Count - Maximum number of characters allowed
- Max Character Count Message - Maximum number of characters allowed error message
- Max Word Count - Maximum number of words allowed
- Max Word Count Message - Maximum number of words allowed error message
- Display Character Count - Confirm that you want to apply and display the character count on page
- Display Character Count Location - Confirm if you want to display the count on the left or right
- Display Word Count - Confirm that you want to apply and display the word count on page
- Display Word Count Location - Confirm if you want to display the count on the left or right

### output parameters
- Value - The content in the text area


## IMPORTNT
When using across multiple screens ensure you set Advanced > Refresh inputs to incorporate changes else-where in the flow