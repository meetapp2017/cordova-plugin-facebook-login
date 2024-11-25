var exec = require('cordova/exec');

/**
 * Метод за логин с Facebook
 * @param {Object} options - Опции за Facebook логин (например permissions)
 * @param {Function} success - Callback при успешен логин
 * @param {Function} error - Callback при грешка
 */
exports.loginWithFacebook = function (options, success, error) {
    exec(success, error, 'FacebookLogin', 'loginWithFacebook', [options]);
};
