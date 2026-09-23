import { createElement } from '@lwc/engine-dom';
import H8FormManager from 'c/h8FormManager';
import flowForms from '@salesforce/apex/H8FlowFormCloneController.getFlowForms';

jest.mock(
    '@salesforce/apex/H8FlowFormCloneController.getFlowForms',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/H8FlowFormManagerController.getFormSections',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/H8FlowFormManagerController.getSectionValidations',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/H8FlowFormManagerController.getFlowRecordUrl',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

describe('c-h8-form-manager', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('loads the available forms on load', async () => {
        flowForms.mockResolvedValue(JSON.stringify({ forms: [{ masterLabel: 'Test Form', developerName: 'Test_Form' }] }));

        const element = createElement('c-h8-form-manager', {
            is: H8FormManager
        });
        document.body.appendChild(element);

        await Promise.resolve();

        const combobox = element.shadowRoot.querySelector('lightning-combobox');
        expect(combobox).not.toBeNull();
        expect(combobox.options).toEqual([{ label: 'Test Form', value: 'Test_Form' }]);
    });
});
