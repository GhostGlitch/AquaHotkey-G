// cl.exe /O2 /favor:AMD64 /LD Array.Sort.c ole32.lib oleaut32.lib

#include <windows.h>
#include <oleauto.h>
#include <oaidl.h>
#include <initguid.h>

typedef int (*ComparatorFunc)(VARIANT*, VARIANT*);

void QuickSort(IDispatch*, IDispatchVtbl*, DISPID, DISPID, int, int, ComparatorFunc);
int Partition(IDispatch*, IDispatchVtbl*, DISPID, DISPID, int, int, ComparatorFunc);
void SwapElements(IDispatch*, IDispatchVtbl*, DISPID, DISPID, int, int);
HRESULT InvokeGet(IDispatch*, IDispatchVtbl*, DISPID, int, VARIANT*);
HRESULT InvokeSet(IDispatch*, IDispatchVtbl*, DISPID, int, VARIANT*);

__declspec(dllexport) int sort(
	VARIANT* pVariant,
	DWORD dwLen,
	ComparatorFunc comparator)
{
    if (!pVariant || pVariant->vt != VT_DISPATCH || !pVariant->pdispVal) {
        return -1;
    }

	IDispatch* pDisp = pVariant->pdispVal;
	IDispatchVtbl* lpVtbl = pDisp->lpVtbl;
	DISPID dispidGet = 0;
	DISPID dispidSet = 0;
	LPOLESTR get = L"Get";
	LPOLESTR set = L"__Item";

    HRESULT hr;
	hr = lpVtbl->GetIDsOfNames(pDisp, &IID_NULL, &get, 1, 0, &dispidGet);
    if (FAILED(hr)) return -2;

	hr = lpVtbl->GetIDsOfNames(pDisp, &IID_NULL, &set, 1, 0, &dispidSet);
    if (FAILED(hr)) return -3;

	VARIANT index = { .vt = VT_I4, .lVal = 2 };
	DISPPARAMS indexArg = { &index, NULL, 1, 0 };

	QuickSort(pDisp, lpVtbl, dispidGet, dispidSet, 0, dwLen - 1, comparator);
    return 0;
}

void QuickSort(
    IDispatch* pDisp, IDispatchVtbl* lpVtbl,
    DISPID dispidGet, DISPID dispidSet,
    int low, int high,
    ComparatorFunc comparator)
{
    if (low >= high) return;

    int pivotIndex = Partition(pDisp, lpVtbl, dispidGet, dispidSet, low, high, comparator);
    QuickSort(pDisp, lpVtbl, dispidGet, dispidSet, low, pivotIndex - 1, comparator);
    QuickSort(pDisp, lpVtbl, dispidGet, dispidSet, pivotIndex + 1, high, comparator);
}

int Partition(
    IDispatch* pDisp, IDispatchVtbl* lpVtbl,
    DISPID dispidGet, DISPID dispidSet,
    int low, int high,
    ComparatorFunc comparator)
{
    VARIANT pivot, temp, v1;
    VariantInit(&pivot);
    VariantInit(&v1);

    InvokeGet(pDisp, lpVtbl, dispidGet, high, &pivot);

    int i = low - 1;
    for (int j = low; j < high; j++) {
        InvokeGet(pDisp, lpVtbl, dispidGet, j, &v1);
        if (comparator(&v1, &pivot) < 0) {
            i++;
            SwapElements(pDisp, lpVtbl, dispidGet, dispidSet, i, j);
        }
        VariantClear(&v1);
    }

    SwapElements(pDisp, lpVtbl, dispidGet, dispidSet, i + 1, high);

    VariantClear(&pivot);
    return i + 1;
}

void SwapElements(
    IDispatch* pDisp, IDispatchVtbl* lpVtbl,
    DISPID dispidGet, DISPID dispidSet,
    int i, int j)
{
    VARIANT temp1, temp2;
    VariantInit(&temp1);
    VariantInit(&temp2);

    InvokeGet(pDisp, lpVtbl, dispidGet, i, &temp1);
    InvokeGet(pDisp, lpVtbl, dispidGet, j, &temp2);

    InvokeSet(pDisp, lpVtbl, dispidSet, i, &temp2);
    InvokeSet(pDisp, lpVtbl, dispidSet, j, &temp1);

    VariantClear(&temp1);
    VariantClear(&temp2);
}

HRESULT InvokeGet(
    IDispatch* pDisp, IDispatchVtbl* lpVtbl,
    DISPID dispidGet,
    int index,
    VARIANT* result)
{
    VARIANT idx = { .vt = VT_I4, .lVal = index + 1 };
    DISPPARAMS params = { &idx, NULL, 1, 0 };
    return lpVtbl->Invoke(pDisp, dispidGet, &IID_NULL, LOCALE_USER_DEFAULT,
                          DISPATCH_METHOD, &params, result, NULL, NULL);
}

HRESULT InvokeSet(
    IDispatch* pDisp, IDispatchVtbl* lpVtbl,
    DISPID dispidSet,
    int index,
    VARIANT* value)
{
    VARIANT args[2];
    args[0].vt    = value->vt;
    args[0].llVal = value->llVal;
    args[1].vt    = VT_I4;
    args[1].llVal = index + 1;

    DISPPARAMS params = {
        .cArgs = 2,
        .cNamedArgs = 0,
        .rgvarg = args
    };
    
    return lpVtbl->Invoke(pDisp, dispidSet, &IID_NULL, LOCALE_USER_DEFAULT,
                          DISPATCH_PROPERTYPUT, &params, NULL, NULL, NULL);
}
