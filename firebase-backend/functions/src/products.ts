export interface ProductData {
  productId: string;
  type: "SUBSCRIPTION" | "NON_SUBSCRIPTION";
}

export const productDataMap: {[productId: string]: ProductData;} = {
  "hangr_pro": {
    productId: "hangr_pro",
    type: "SUBSCRIPTION",
  },
};
