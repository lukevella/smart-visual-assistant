//  OpenEars _version 1.0_
//  http://www.politepix.com/openears
//
//  LanguageModelGenerator.h
//  OpenEars
//
//  LanguageModelGenerator is a class which creates new grammars
//
//  Copyright Politepix UG (haftungsbeschränkt) 2012. All rights reserved.
//  http://www.politepix.com
//  Contact at http://www.politepix.com/contact
//
//  This file is licensed under the Politepix Shared Source license found in the root of the source distribution.

@interface LanguageModelGenerator : NSObject {

}

- (NSError *) generateLanguageModelFromArray:(NSArray *)languageModelArray withFilesNamed:(NSString *)fileName;

@end
