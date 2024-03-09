//
//  NicknameTextField.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct NicknameTextField: View {
    @Binding private var nickname: String
    @Binding private var isValid: Bool
    @FocusState private var isFocused: Bool
    private let focusedWhenAppearing: Bool
    
    init(
        nickname: Binding<String>,
        isValid: Binding<Bool>,
        focusedWhenAppearing: Bool
    ) {
        self._nickname = nickname
        self._isValid = isValid
        self.focusedWhenAppearing = focusedWhenAppearing
    }
    
    var body: some View {
        VStack(spacing: 10) {
            nicknameRules
            textField
        }
    }
    
    private let nicknameMaxLength: Int = 10
    
    private var nicknameRules: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(
                    String(
                        localized: "nicknameTextField.nicknameLengthRules",
                        defaultValue: "Please enter a nickname between 1 and 10 characters."
                    )
                    
                )

            } icon: {
                nicknameRuleSymbol(isValidLength(self.nickname))
            }
            .animation(.default, value: isValidLength(self.nickname))
            
            Label {
                Text(
                    String(
                        localized: "nicknameTextField.nicknameLetterRules",
                        defaultValue: "Please create a nickname using English, numbers, and Korean."
                    )
                )
            } icon: {
                nicknameRuleSymbol(isValidLetter(self.nickname))
            }
            .animation(.default, value: isValidLetter(self.nickname))
        }
        .font(.caption.weight(.semibold))
        .onChange(of: nickname) { text in
            self.isValid = isValidLength(text) && isValidLetter(text)
        }
        
    }
    
    private func nicknameRuleSymbol(_ isValid: Bool) -> some View {
        if isValid {
            Image(systemName: "checkmark.circle")
                .foregroundStyle(.green)
                
        } else {
            Image(systemName: "xmark.circle")
                .foregroundStyle(.red)
        }
    }
    
    @Environment(\.colorScheme) private var scheme
    private var textField: some View {
        VStack(spacing: 0) {
            TextField(text: $nickname) {
                // "별명 입력"
                Text(
                    String(
                        localized: "nicknameTextField.prompt",
                        defaultValue: "Please enter your nickname."
                    )
                )
                .foregroundStyle(.gray)
            }
            .nicknameTextFieldStyle()
            .focused($isFocused)
            .onAppear {
                if focusedWhenAppearing {
                    isFocused = true
                }                
            }
            
            HStack {
                Spacer()
                Text("\(nickname.count)/\(nicknameMaxLength)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 23)
            }
        }
    }
    
    private func isValidLength(_ input: String) -> Bool {
        return (input.count <= nicknameMaxLength) && !input.isEmpty
    }
    
    private func isValidLetter(_ input: String) -> Bool {
        let pattern = "^[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣]*$"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex.firstMatch(in: input, options: [], range: range) != nil
    }
}

private struct NicknameTextFieldStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme: ColorScheme
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .font(.body.weight(.semibold))
            .foregroundStyle(.hhAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 73)
            .background {
                RoundedRectangle(cornerRadius: 17, style: .circular)
                    .foregroundStyle(.hhTertiary)
            }
    }
}

extension View {
    func nicknameTextFieldStyle() -> some View {
        modifier(NicknameTextFieldStyleModifier())
    }
}

#Preview {
    @State var text: String = ""
    @State var isValid: Bool = false
    
    return NicknameTextField(nickname: $text, isValid: $isValid, focusedWhenAppearing: true)
}
