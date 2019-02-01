

bool isNullEmpty(String o) =>
  o == null || "" == o;

bool isNullEmptyOrFalse(Object o) =>
  o == null || false == o || "" == o;

bool isNullEmptyFalseOrZero(Object o) =>
  o == null || false == o || 0 == o || "" == o;