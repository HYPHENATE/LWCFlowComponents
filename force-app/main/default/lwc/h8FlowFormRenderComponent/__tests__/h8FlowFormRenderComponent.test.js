import { createElement } from '@lwc/engine-dom';
import H8FlowFormRenderComponent from 'c/h8FlowFormRenderComponent';
import getForm from '@salesforce/apex/H8FlowFormController.getForm';

jest.mock(
    '@salesforce/apex/H8FlowFormController.getForm',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/H8FlowFormValidation.validateCompleteForm',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/H8FlowFormSectionValidation.validatePage',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

const flushPromises = () => Promise.resolve();

describe('c-h8-flow-form-render-component', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        document.title = '';
        sessionStorage.clear();
        jest.clearAllMocks();
    });

    it('prefixes the original page title with the active section label', async () => {
        document.title = 'Submit | Individual Application: IA-0000000860';

        getForm.mockResolvedValue(JSON.stringify({
            success: true,
            formDeveloperName: 'Individual_Application',
            masterObject: 'Individual_Application__c',
            sections: [
                {
                    id: 'section-1',
                    label: 'Personal Details',
                    flow: 'Personal_Details_Flow',
                    hasConfiguredValidations: false
                },
                {
                    id: 'section-2',
                    label: 'Supporting Information',
                    flow: 'Supporting_Information_Flow',
                    hasConfiguredValidations: false
                }
            ]
        }));

        const element = createElement('c-h8-flow-form-render-component', {
            is: H8FlowFormRenderComponent
        });
        element.formName = 'Individual_Application';
        element.recordId = 'a00000000000001';

        document.body.appendChild(element);
        await flushPromises();
        await flushPromises();

        expect(document.title).toBe(
            'Personal Details | Submit | Individual Application: IA-0000000860'
        );

        const navItems = element.shadowRoot.querySelectorAll('c-h8-flow-form-render-item');
        navItems[1].dispatchEvent(
            new CustomEvent('sectionselected', {
                detail: {
                    sectionId: 'section-2',
                    flowName: 'Supporting_Information_Flow'
                }
            })
        );

        expect(document.title).toBe(
            'Supporting Information | Submit | Individual Application: IA-0000000860'
        );
    });
});
