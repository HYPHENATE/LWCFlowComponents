import {
    flowComboboxDefaults,
    formattedValue,
    getDataType,
    isReference,
    removeFormatting
} from 'c/h8DataFetcherCPEComboboxUtils';

describe('c/h8DataFetcherCPEComboboxUtils (legacy path test)', () => {
    it('detects references and data types', () => {
        expect(isReference('{!MyVar}')).toBe(true);
        expect(isReference('MyVar')).toBe(false);

        expect(getDataType('{!MyVar}')).toBe(flowComboboxDefaults.referenceDataType);
        expect(getDataType('Hello')).toBe(flowComboboxDefaults.stringDataType);
    });

    it('formats and removes formatting', () => {
        expect(formattedValue('MyVar', flowComboboxDefaults.referenceDataType)).toBe('{!MyVar}');
        expect(formattedValue('{!MyVar}', flowComboboxDefaults.referenceDataType)).toBe('{!MyVar}');
        expect(formattedValue('Hello', flowComboboxDefaults.stringDataType)).toBe('Hello');

        expect(removeFormatting('{!MyVar}')).toBe('MyVar');
        expect(removeFormatting('Hello')).toBe('Hello');
        expect(removeFormatting(null)).toBe(null);
    });
});
