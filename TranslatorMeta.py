import locale

class TranslatorMeta(type):
    """Metaclass for ad-hoc translations, examle below

    ```
    class DialogTranslator(metaclass=TranslatorMeta):
        RU = "ru"
        Title_connectivity_problem = "Connectivity problem with", {RU: "Проблема связи с"}
        Cant_fetch_correct_data = "Failed getting correct info from server", {
            RU: "Не удаётся получить корректные данные с сервера"
        }
        Retry = "Retry", {RU: "Повторить попытку"}
        Cancel = "Cancel", {RU: "Отменить"}
    ```

    Then can be used like
    ```
    _ = DialogTranslator()
    print(_.Title_connectivity_problem)
    ```
    """

    def __new__(mcs, name, bases, attrs, **kwargs):
        "Replaces class attrs containing translation variants with their translations"
        lang = locale.getlocale(locale.LC_MESSAGES)[0]
        translated_attrs = {}
        for attr_name, base_and_langs in attrs.items():
            match base_and_langs:
                case (base, langs):
                    translated_attrs[attr_name] = base
                    if lang:
                        for trans_lang, trans in langs.items():
                            if lang.startswith(trans_lang):
                                translated_attrs[attr_name] = trans
        return super().__new__(mcs, name, bases, translated_attrs, **kwargs)
